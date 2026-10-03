import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface JoobleJob {
  id: number | string;
  title: string;
  location: string;
  snippet: string;
  salary?: string;
  source?: string;
  type?: string;
  link?: string;
  company?: string;
  updated?: string;
}

const COMMON_SKILLS = [
  "Flutter", "Dart", "React", "React Native", "TypeScript", "JavaScript",
  "Node.js", "Python", "Java", "Kotlin", "Swift", "C#", ".NET", "PHP",
  "Laravel", "Go", "Golang", "SQL", "PostgreSQL", "MySQL", "MongoDB",
  "Docker", "Kubernetes", "AWS", "Azure", "GCP", "Git", "REST APIs", "GraphQL",
  "Figma", "UI/UX", "Customer Support", "BPO", "Technical Support", "QA", "Sales"
];

const PH_COORDINATES: Record<string, { lat: number; lng: number }> = {
  "manila": { lat: 14.5995, lng: 120.9842 },
  "taguig": { lat: 14.5547, lng: 121.0244 },
  "bgc": { lat: 14.5547, lng: 121.0244 },
  "makati": { lat: 14.5547, lng: 121.0244 },
  "pasig": { lat: 14.5866, lng: 121.0614 },
  "ortigas": { lat: 14.5866, lng: 121.0614 },
  "quezon city": { lat: 14.6760, lng: 121.0437 },
  "cebu": { lat: 10.3157, lng: 123.8854 },
  "davao": { lat: 7.1907, lng: 125.4504 },
  "clark": { lat: 15.1450, lng: 120.5887 },
  "angeles": { lat: 15.1450, lng: 120.5887 },
  "iloilo": { lat: 10.7202, lng: 122.5621 },
  "cagayan de oro": { lat: 8.4542, lng: 124.6319 },
  "cdo": { lat: 8.4542, lng: 124.6319 },
  "baguio": { lat: 16.4023, lng: 120.5960 },
  "muntinlupa": { lat: 14.4081, lng: 121.0415 },
  "alabang": { lat: 14.4250, lng: 121.0270 },
  "mandaluyong": { lat: 14.5794, lng: 121.0359 }
};

function cleanHtml(raw: string): string {
  if (!raw) return "";
  return raw
    .replace(/<li\b[^>]*>/gi, "\n- ")
    .replace(/<\/(?:li|p|div|section|h[1-6])>/gi, "\n")
    .replace(/<(?:br|p|div|section|h[1-6])\b[^>]*>/gi, "\n")
    .replace(/<[^>]*>/g, "")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/\r\n?/g, "\n")
    .replace(/[ \t]+/g, " ")
    .replace(/ *\n */g, "\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

function detectWorkMode(text: string, location: string): "remote" | "hybrid" | "onSite" {
  const combined = (text + " " + location).toLowerCase();
  if (combined.includes("remote") || combined.includes("wfh") || combined.includes("work from home")) {
    return "remote";
  }
  if (combined.includes("hybrid") || combined.includes("flexible")) {
    return "hybrid";
  }
  return "onSite";
}

function detectEmploymentType(typeStr?: string, snippet?: string): "fullTime" | "partTime" | "contract" {
  const combined = ((typeStr ?? "") + " " + (snippet ?? "")).toLowerCase();
  if (combined.includes("part-time") || combined.includes("part time")) return "partTime";
  if (combined.includes("contract") || combined.includes("freelance") || combined.includes("project")) return "contract";
  return "fullTime";
}

function extractSkills(text: string): string[] {
  const lower = text.toLowerCase();
  const matched: string[] = [];
  for (const s of COMMON_SKILLS) {
    if (lower.includes(s.toLowerCase())) {
      matched.push(s);
    }
  }
  return matched.slice(0, 8);
}

function parseSalary(salaryStr?: string): { min?: number; max?: number } {
  if (!salaryStr) return {};
  const cleaned = salaryStr.replace(/,/g, "");
  const nums = cleaned.match(/\d+/g);
  if (!nums || nums.length === 0) return {};
  if (nums.length === 1) {
    const val = parseInt(nums[0], 10);
    return val > 0 ? { min: val, max: val } : {};
  }
  const min = parseInt(nums[0], 10);
  const max = parseInt(nums[1], 10);
  return {
    min: Math.min(min, max),
    max: Math.max(min, max),
  };
}

function findCoordinates(location: string): { lat?: number; lng?: number } {
  const locLower = location.toLowerCase();
  for (const [key, coords] of Object.entries(PH_COORDINATES)) {
    if (locLower.includes(key)) {
      return coords;
    }
  }
  // Default Philippines fallback center if marked Philippines
  if (locLower.includes("philippines")) {
    return { lat: 14.5995, lng: 120.9842 }; // Manila default
  }
  return {};
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    let keywords = "developer";
    let location = "Philippines";
    let page = 1;
    let forceRefresh = false;

    if (req.method === "POST") {
      try {
        const body = await req.json();
        keywords = body.keywords ?? body.query ?? keywords;
        location = body.location ?? location;
        page = typeof body.page === "number" ? body.page : 1;
        forceRefresh = Boolean(body.forceRefresh);
      } catch {
        // empty body, use defaults
      }
    } else {
      const url = new URL(req.url);
      keywords = url.searchParams.get("keywords") ?? url.searchParams.get("query") ?? keywords;
      location = url.searchParams.get("location") ?? location;
      const pageParam = url.searchParams.get("page");
      if (pageParam) page = parseInt(pageParam, 10) || 1;
      forceRefresh = url.searchParams.get("forceRefresh") === "true";
    }

    const joobleApiKey = Deno.env.get("JOOBLE_API_KEY");
    if (!joobleApiKey) {
      return new Response(
        JSON.stringify({ error: "JOOBLE_API_KEY is not configured on the server." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 1. Quota Guard & Cache check:
    // If not forcing refresh, check if we already have matching active jobs in the DB fetched within the last 24h
    if (!forceRefresh) {
      let dbQuery = supabase
        .from("jobs")
        .select("*")
        .eq("active", true)
        .eq("source", "jooble")
        .order("published_at", { ascending: false })
        .limit(20);

      if (keywords.trim().length > 0 && keywords !== "developer") {
        dbQuery = dbQuery.ilike("role", `%${keywords.trim()}%`);
      }
      if (location.trim().length > 0 && location !== "Philippines") {
        dbQuery = dbQuery.ilike("location", `%${location.trim()}%`);
      }

      const { data: cachedJobs, error: cacheErr } = await dbQuery;
      if (!cacheErr && cachedJobs && cachedJobs.length >= 5) {
        return new Response(
          JSON.stringify({
            source: "cache",
            totalCount: cachedJobs.length,
            jobs: cachedJobs,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    }

    // 2. Query Jooble API securely on the server
    const joobleEndpoint = `https://ph.jooble.org/api/${joobleApiKey}`;
    const joobleRes = await fetch(joobleEndpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        keywords: keywords.trim(),
        location: location.trim(),
        page,
        ResultOnPage: 20,
      }),
    });

    if (!joobleRes.ok) {
      const errText = await joobleRes.text();
      return new Response(
        JSON.stringify({ error: `Jooble API responded with status ${joobleRes.status}`, details: errText }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const joobleData = await joobleRes.json();
    const rawJobs: JoobleJob[] = joobleData.jobs ?? [];

    // 3. Transform and Normalize into Rolevia Job Model
    const normalizedJobs = [];
    for (const r of rawJobs) {
      const role = cleanHtml(r.title);
      const company = r.company ? cleanHtml(r.company) : "Direct Employer";
      const loc = cleanHtml(r.location);
      const overview = cleanHtml(r.snippet);
      const mode = detectWorkMode(role + " " + overview, loc);
      const type = detectEmploymentType(r.type, overview);
      const skills = extractSkills(role + " " + overview);
      const { min: salaryMin, max: salaryMax } = parseSalary(r.salary);
      const coords = findCoordinates(loc);
      const publishedAt = r.updated ? new Date(r.updated).toISOString() : new Date().toISOString();
      const applyUrl = r.link ?? "";

      normalizedJobs.push({
        source: "jooble",
        source_id: String(r.id),
        role,
        company,
        location: loc,
        work_mode: mode,
        employment_type: type,
        overview,
        original_description: overview,
        description_truncated: true,
        description_source: "snippet",
        skills,
        responsibilities: [],
        qualifications: [],
        salary_min: salaryMin ?? null,
        salary_max: salaryMax ?? null,
        salary_currency: "PHP",
        salary_period: "month",
        application_url: applyUrl.startsWith("http") ? applyUrl : null,
        published_at: publishedAt,
        active: true,
        latitude: coords.lat ?? null,
        longitude: coords.lng ?? null,
      });
    }

    // 4. Upsert into Supabase public.jobs table (persisting real jobs into DB)
    if (normalizedJobs.length > 0) {
      try {
        const { error: upsertErr } = await supabase
          .from("jobs")
          .upsert(normalizedJobs, { onConflict: "source,source_id" });

        if (upsertErr) {
          console.error("Upsert notice:", upsertErr.message);
        }
      } catch (err) {
        console.error("Failed to upsert jobs into DB:", err);
      }
    }

    // 5. Query back formatted jobs or map with IDs
    const { data: dbJobs } = await supabase
      .from("jobs")
      .select("*")
      .eq("source", "jooble")
      .order("published_at", { ascending: false })
      .limit(20);

    const resultJobs = dbJobs && dbJobs.length > 0 ? dbJobs : normalizedJobs;

    return new Response(
      JSON.stringify({
        source: "jooble_api",
        totalCount: joobleData.totalCount ?? resultJobs.length,
        jobs: resultJobs,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
