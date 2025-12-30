-- Grid data table for storing real-time grid metrics
CREATE TABLE public.grid_data (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  generation_mw NUMERIC,
  frequency NUMERIC,
  load_percent NUMERIC,
  status TEXT CHECK (status IN ('stable', 'stressed', 'critical')),
  source TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS but allow public read access (grid data is public information)
ALTER TABLE public.grid_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Grid data is publicly readable" 
ON public.grid_data 
FOR SELECT 
USING (true);

-- Power reports table for community crowdsourced reports
CREATE TABLE public.power_reports (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID,
  latitude NUMERIC NOT NULL,
  longitude NUMERIC NOT NULL,
  address TEXT,
  region TEXT,
  status TEXT NOT NULL CHECK (status IN ('available', 'unavailable')),
  estimated_duration TEXT,
  upvotes INTEGER NOT NULL DEFAULT 0,
  downvotes INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.power_reports ENABLE ROW LEVEL SECURITY;

-- Anyone can read reports
CREATE POLICY "Power reports are publicly readable" 
ON public.power_reports 
FOR SELECT 
USING (true);

-- Anyone can create reports (anonymous reporting allowed)
CREATE POLICY "Anyone can create power reports" 
ON public.power_reports 
FOR INSERT 
WITH CHECK (true);

-- Distribution companies table
CREATE TABLE public.discos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  short_name TEXT NOT NULL UNIQUE,
  status TEXT CHECK (status IN ('stable', 'stressed', 'critical')),
  load_percent NUMERIC,
  trend TEXT CHECK (trend IN ('up', 'down', 'neutral')),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.discos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Discos are publicly readable" 
ON public.discos 
FOR SELECT 
USING (true);

-- Grid news table
CREATE TABLE public.grid_news (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT CHECK (type IN ('alert', 'info', 'update')),
  region TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.grid_news ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Grid news is publicly readable" 
ON public.grid_news 
FOR SELECT 
USING (true);

-- Enable realtime for all tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.grid_data;
ALTER PUBLICATION supabase_realtime ADD TABLE public.power_reports;
ALTER PUBLICATION supabase_realtime ADD TABLE public.discos;
ALTER PUBLICATION supabase_realtime ADD TABLE public.grid_news;

-- Insert initial DISCO data for Nigeria's 11 distribution companies
INSERT INTO public.discos (name, short_name, status, load_percent, trend) VALUES
  ('Ikeja Electric', 'IE', NULL, NULL, NULL),
  ('Eko Electricity Distribution Company', 'EKEDC', NULL, NULL, NULL),
  ('Ibadan Electricity Distribution Company', 'IBEDC', NULL, NULL, NULL),
  ('Abuja Electricity Distribution Company', 'AEDC', NULL, NULL, NULL),
  ('Enugu Electricity Distribution Company', 'EEDC', NULL, NULL, NULL),
  ('Port Harcourt Electricity Distribution Company', 'PHED', NULL, NULL, NULL),
  ('Kaduna Electric', 'KAEDCO', NULL, NULL, NULL),
  ('Kano Electricity Distribution Company', 'KEDCO', NULL, NULL, NULL),
  ('Jos Electricity Distribution Company', 'JED', NULL, NULL, NULL),
  ('Benin Electricity Distribution Company', 'BEDC', NULL, NULL, NULL),
  ('Yola Electricity Distribution Company', 'YEDC', NULL, NULL, NULL);