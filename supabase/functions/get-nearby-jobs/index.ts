import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const latStr = url.searchParams.get("lat") || url.searchParams.get("latitude");
    const lngStr = url.searchParams.get("lng") || url.searchParams.get("lon") || url.searchParams.get("longitude");
    const radiusStr = url.searchParams.get("radius_km") || url.searchParams.get("radius") || "15";
    const limitStr = url.searchParams.get("limit") || "20";
    const distanceCursorStr = url.searchParams.get("distance_cursor") || "-1";
    const idCursorStr = url.searchParams.get("id_cursor") || "00000000-0000-0000-0000-000000000000";

    const lat = latStr ? parseFloat(latStr) : 14.5547; // Default to Taguig/BGC center
    const lng = lngStr ? parseFloat(lngStr) : 121.0244;
    const radius = Math.min(200, Math.max(0.1, parseFloat(radiusStr) || 15));
    const limit = Math.min(100, Math.max(1, parseInt(limitStr, 10) || 20));
    const distanceCursor = parseFloat(distanceCursorStr) || -1;
    const idCursor = idCursorStr;

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const authHeader = req.headers.get("Authorization");

    const effectiveKey = authHeader ? supabaseAnonKey : (supabaseServiceKey || supabaseAnonKey);
    const client = createClient(supabaseUrl, effectiveKey, {
      global: authHeader ? { headers: { Authorization: authHeader } } : undefined,
    });

    // Try calling nearby_jobs RPC
    const { data: rows, error: rpcError } = await client.rpc("nearby_jobs", {
      p_lat: lat,
      p_lng: lng,
      p_radius: radius,
      p_distance: distanceCursor,
      p_id: idCursor,
      p_limit: limit,
    });

    if (rpcError) {
      // Fallback: If PostGIS extension or RPC is unavailable, select active jobs and calculate Haversine
      const { data: jobs, error: selectError } = await client
        .from("jobs")
        .select("*")
        .eq("active", true)
        .order("published_at", { ascending: false })
        .limit(limit);

      if (selectError) {
        return new Response(JSON.stringify({ error: selectError.message }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const jobsWithDistance = (jobs || []).map(j => {
        let distanceKm = 0;
        if (j.latitude != null && j.longitude != null) {
          distanceKm = computeHaversine(lat, lng, j.latitude, j.longitude);
        }
        return {
          ...j,
          distance_km: Math.round(distanceKm * 10) / 10,
        };
      });

      return new Response(JSON.stringify(jobsWithDistance), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const formattedJobs = (rows || []).map((r: { job: Record<string, unknown>; distance_m: number }) => ({
      ...r.job,
      distance_km: Math.round((r.distance_m / 1000) * 10) / 10,
    }));

    return new Response(JSON.stringify(formattedJobs), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

function computeHaversine(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
