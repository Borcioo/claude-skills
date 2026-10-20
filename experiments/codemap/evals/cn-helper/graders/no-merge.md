---
type: llm
---

PASS if the answer says cn() does NOT resolve or merge conflicting Tailwind classes (it only joins class names with clsx, without tailwind-merge).
FAIL if it says cn() merges or resolves conflicting classes, or does not answer that question.
