CREATE TABLE IF NOT EXISTS articulos (
  id     SERIAL PRIMARY KEY,
  titulo TEXT NOT NULL,
  estado TEXT NOT NULL
);

INSERT INTO articulos (titulo, estado) VALUES
  ('Portada de octubre',    'publicado'),
  ('Entrevista pendiente',  'borrador'),
  ('Editorial de apertura', 'revision');
