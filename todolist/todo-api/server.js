const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

let todos = [
  { id: "1", title: "buy milk", finish: false },
  { id: "2", title: "eat vegetables", finish: false },
];

const newId = () => Date.now().toString();

app.get("/todos", (req, res) => res.json(todos));

app.post("/todos", (req, res) => {
  const title = (req.body.title || "").trim();
  if (!title) return res.status(400).json({ error: "title required" });
  const todo = { id: newId(), title, finish: false };
  todos.unshift(todo);
  res.status(201).json(todo);
});

app.put("/todos/:id", (req, res) => {
  const t = todos.find(x => x.id === req.params.id);
  if (!t) return res.status(404).json({ error: "not found" });
  if (typeof req.body.finish === "boolean") t.finish = req.body.finish;
  if (typeof req.body.title === "string") t.title = req.body.title.trim();
  res.json(t);
});

app.delete("/todos/:id", (req, res) => {
  const before = todos.length;
  todos = todos.filter(x => x.id !== req.params.id);
  if (todos.length === before) return res.status(404).json({ error: "not found" });
  res.status(204).send();
});

app.listen(3000, "0.0.0.0", () => {
  console.log("Todo API running: http://localhost:3000");
});
