import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { nanoid } from 'nanoid';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const DB_PATH = path.join(__dirname, 'db.json');

const app = express();
app.use(cors());
app.use(bodyParser.json());

function readDb() {
  if (!fs.existsSync(DB_PATH)) {
    fs.writeFileSync(DB_PATH, JSON.stringify({ tasks: [], categories: ["work", "personal"] }, null, 2));
  }
  return JSON.parse(fs.readFileSync(DB_PATH, 'utf-8'));
}

function writeDb(db) {
  fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2));
}

app.get('/api/tasks', (req, res) => {
  const db = readDb();
  res.json(db.tasks);
});

app.get('/api/tasks/:id', (req, res) => {
  const db = readDb();
  const t = db.tasks.find(x => x.id === req.params.id);
  if (!t) return res.status(404).json({ message: 'Not found' });
  res.json(t);
});

app.post('/api/tasks', (req, res) => {
  const db = readDb();
  const body = req.body || {};
  const now = new Date().toISOString();
  const task = {
    id: body.id || nanoid(16),
    title: body.title || '(untitled)',
    description: body.description || null,
    status: body.status || 'pending',
    category: body.category || '',
    priority: body.priority || 'medium',
    dueDate: body.dueDate || null,
    createdAt: body.createdAt || now,
    updatedAt: body.updatedAt || now
  };
  db.tasks.push(task);
  writeDb(db);
  res.status(201).json(task);
});

app.put('/api/tasks/:id', (req, res) => {
  const db = readDb();
  const idx = db.tasks.findIndex(x => x.id === req.params.id);
  if (idx === -1) return res.status(404).json({ message: 'Not found' });
  const body = req.body || {};
  db.tasks[idx] = { ...db.tasks[idx], ...body, updatedAt: body.updatedAt || new Date().toISOString() };
  writeDb(db);
  res.json(db.tasks[idx]);
});

app.delete('/api/tasks/:id', (req, res) => {
  const db = readDb();
  const idx = db.tasks.findIndex(x => x.id === req.params.id);
  if (idx === -1) return res.status(404).json({ message: 'Not found' });
  db.tasks.splice(idx, 1);
  writeDb(db);
  res.status(204).end();
});

app.get('/api/categories', (req, res) => {
  const db = readDb();
  res.json(db.categories || []);
});

const PORT = process.env.PORT || 3333;
app.listen(PORT, () => {
  console.log(`Mock API listening on http://localhost:${PORT}`);
});


