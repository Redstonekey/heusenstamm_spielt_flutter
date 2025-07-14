-- Tournaments table
CREATE TABLE public.tournaments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  description text,
  method text NOT NULL, -- 'manual' or 'schema'
  schema_type text,     -- e.g. 'tree', 'duel', etc. (nullable for manual)
  created_by uuid REFERENCES auth.users(id),
  created_at timestamp with time zone DEFAULT now()
);

-- Tournament participants (can be user or just a name)
CREATE TABLE public.tournament_participants (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  tournament_id uuid REFERENCES tournaments(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id),
  display_name text NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

-- Tournament matches
CREATE TABLE public.tournament_matches (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  tournament_id uuid REFERENCES tournaments(id) ON DELETE CASCADE,
  round integer NOT NULL,
  match_index integer NOT NULL, -- index in the round
  participant1_id uuid REFERENCES tournament_participants(id),
  participant2_id uuid REFERENCES tournament_participants(id),
  score1 integer,
  score2 integer,
  winner_id uuid REFERENCES tournament_participants(id),
  next_match_id uuid REFERENCES tournament_matches(id), -- for tree schemas
  visible_to_players boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

-- Indexes for performance
CREATE INDEX idx_tournament_participants_tournament_id ON tournament_participants(tournament_id);
CREATE INDEX idx_tournament_matches_tournament_id ON tournament_matches(tournament_id);
