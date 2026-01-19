# Progress
Agent to replace this section when appropriate...

# Intro
- This document contains instructions for a task
- Review the whole doc and ask me for more info if needed
- Check for edge cases or design flaws or features that I may have missed and ask me for clarification if necessary
- At significant points during the task, replace the #Progress section with a progress update. Keep progress updates concise. They should only contain enough for me to decide if I need to assist or course-correct
- After completion of all tasks, prepend a summary of changes to this todo doc for me to review

# Task details...

- This task depends on the todo/node.md task being complete first
- Add features for the following tools. Follow the similar patterns in gemini-cli for npm based installs, or claude-code for curl install scripts. 
- Add test scenarios.json - examine other `test/*/scenarios.json` for the pattern to follow.
- Create a new git branch for each feature to work on

Below are the tool websites followed by their documented install command. 

- https://openai.com/codex/ npm i -g @openai/codex
- https://ampcode.com/ curl -fsSL https://ampcode.com/install.sh | bash
- https://block.github.io/goose/docs/quickstart curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash
- https://factory.ai/ curl -fsSL https://app.factory.ai/cli | sh
- https://docs.letta.com/letta-code npm install -g @letta-ai/letta-code

- https://aider.chat/docs/install.html - we're having a problem with aider branch re pip path. It's not high priority to fix
