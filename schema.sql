-- Atlas cloud storage schema.
-- Run this entire file in Supabase SQL Editor.

create table if not exists public.library_items (
  -- Atlas keeps stable browser-friendly ids such as a-... for local imports.
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null default '灵感',
  title text not null default '未命名收藏',
  category text not null default '待整理',
  url text not null default '',
  summary text not null default '',
  prompt text not null default '',
  tags jsonb not null default '[]'::jsonb,
  note text not null default '',
  image_path text not null default '',
  image_url text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.library_items enable row level security;

drop policy if exists "Atlas users can read their own items" on public.library_items;
create policy "Atlas users can read their own items"
  on public.library_items for select
  using (auth.uid() = user_id);

drop policy if exists "Atlas users can insert their own items" on public.library_items;
create policy "Atlas users can insert their own items"
  on public.library_items for insert
  with check (auth.uid() = user_id);

drop policy if exists "Atlas users can update their own items" on public.library_items;
create policy "Atlas users can update their own items"
  on public.library_items for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Atlas users can delete their own items" on public.library_items;
create policy "Atlas users can delete their own items"
  on public.library_items for delete
  using (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('atlas-assets', 'atlas-assets', false)
on conflict (id) do update set public = false;

drop policy if exists "Atlas users can read their own assets" on storage.objects;
create policy "Atlas users can read their own assets"
  on storage.objects for select
  using (bucket_id = 'atlas-assets' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Atlas users can upload their own assets" on storage.objects;
create policy "Atlas users can upload their own assets"
  on storage.objects for insert
  with check (bucket_id = 'atlas-assets' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Atlas users can update their own assets" on storage.objects;
create policy "Atlas users can update their own assets"
  on storage.objects for update
  using (bucket_id = 'atlas-assets' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'atlas-assets' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Atlas users can delete their own assets" on storage.objects;
create policy "Atlas users can delete their own assets"
  on storage.objects for delete
  using (bucket_id = 'atlas-assets' and (storage.foldername(name))[1] = auth.uid()::text);

create index if not exists library_items_user_updated_idx
  on public.library_items (user_id, updated_at desc);
