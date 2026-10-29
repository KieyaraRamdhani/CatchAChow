-- CatchAChow optional Supabase data model starter.
-- Run in Supabase SQL editor only after reviewing it for your deployment.
-- Auth user IDs are the ownership boundary. Never put provider secrets in client tables.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  first_name text,
  surname text,
  date_of_birth date,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pantry_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  item_name text not null,
  quantity text,
  expires_on date,
  created_at timestamptz not null default now()
);

create table if not exists public.saved_meal_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  budget_zar numeric(10,2) not null check (budget_zar >= 0),
  people integer not null default 1 check (people between 1 and 30),
  days integer not null default 1 check (days between 1 and 31),
  plan_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.price_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_name text not null,
  retailer text,
  target_price_zar numeric(10,2) not null check (target_price_zar >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.shared_baskets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'Shared student basket',
  budget_zar numeric(10,2) not null default 0 check (budget_zar >= 0),
  basket_json jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  plan_code text not null check (plan_code in ('free','premium_monthly','premium_yearly')),
  status text not null default 'free' check (status in ('free','pending','active','past_due','cancelled','expired')),
  current_period_end timestamptz,
  payment_provider text,
  provider_customer_id text,
  provider_subscription_id text,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.pantry_items enable row level security;
alter table public.saved_meal_plans enable row level security;
alter table public.price_alerts enable row level security;
alter table public.shared_baskets enable row level security;
alter table public.subscriptions enable row level security;

create policy "profiles read own" on public.profiles for select to authenticated using (auth.uid() = id);
create policy "profiles insert own" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "profiles update own" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "pantry own rows" on public.pantry_items for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "meal plans own rows" on public.saved_meal_plans for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "price alerts own rows" on public.price_alerts for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "shared baskets owner only" on public.shared_baskets for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
-- Intentionally no client write policy for subscriptions. Only a trusted backend with service credentials
-- should change paid status after verifying the payment provider's signed webhook.
create policy "subscription read own" on public.subscriptions for select to authenticated using (auth.uid() = user_id);
