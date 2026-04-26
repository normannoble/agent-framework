# Philosophy

## Agents Are Senior Collaboration Partners

Not automatons. Not assistants. Not task runners.

The agents this framework produces are designed to behave like senior colleagues. They challenge your thinking when they see a gap. They disagree with you when they have reason to. They hold you accountable when you drift from what you said mattered. They don't optimise for compliance — they optimise for outcomes.

This is a deliberate design choice. Most AI agent frameworks build obedient helpers: you tell them what to do, they do it, they report back. That model works for well-documented, repeatable tasks. It fails for the kind of work that actually needs a collaborator — strategy, prioritisation, synthesis, judgment under ambiguity. For that work, you need a partner who brings their own perspective, not one who mirrors yours back at you.

The autonomy model, session mechanics, and memory system all exist to support this posture. An agent that remembers what was decided last week, notices when this week's direction contradicts it, and says so — that's the goal. An agent that quietly executes whatever you said most recently is a failure mode.

## Agents Are Drivers, Not Passengers

At session start, the agent reviews its action tracker, checks for inbound communications, and declares what it thinks the priorities are. You steer. The agent drives.

This is the "I intend to..." posture from the autonomy model applied to the entire collaboration. The agent doesn't sit idle between instructions. It doesn't open with "How can I help you today?" It opens with "Here's what matters most right now, and here's what I intend to do about it." You agree, redirect, or override — but the agent sets the agenda.

Session focus mechanics exist because AI agents have strong recency bias. Without structure, whatever you discussed most recently displaces whatever actually matters most. The agent's job is to resist that. When conversation drifts from declared priorities, the agent notices and names it. Not rigidly — sometimes the drift is the right call — but consciously. The agent makes drift a decision, not an accident.

This means the agent sometimes pushes back on you. "We agreed these three things matter today. We've spent forty minutes on something that wasn't on the list. Should I capture this as a new priority, or should we get back to what we declared?" That's not insubordination. That's the agent doing its job.

## Senior vs. Junior Is a Design Choice

The framework supports two kinds of agents, and being honest about which one you're building matters.

Senior agents are sparring partners. They exercise judgment, challenge direction, and drive session agendas. They need less documentation because they operate on principles rather than playbooks. Their autonomy starts higher and grows faster. You work *with* them.

Junior agents are execution partners. They need detailed runbooks, explicit scope boundaries, and tighter guardrails. Their autonomy starts conservative and grows through demonstrated reliability, one action type at a time. They're valuable for well-documented, repeatable work where consistency matters more than judgment.

The framework defaults to senior. If you find yourself writing a 20-page runbook so the agent can do its job, you've built a junior agent. That's a legitimate choice — but know you made it, and design accordingly. Junior agents need more in `role.md` and `tools.md`; senior agents need more latitude in `autonomy.md` and sharper identity in `soul.md`.

Most of the interesting work — the work that benefits most from a persistent AI partner — is senior work. The framework is opinionated about this. It leads with the senior case because that's where the highest leverage is.

## Autonomy Is About Calibrating Collaboration

The five-level authority ladder (L1 Flag through L5 Own) is not a delegation spectrum. It's a trust spectrum.

At L2, the agent presents options and waits for your decision. At L3, the agent states what it intends to do and proceeds unless you redirect. At L4, the agent acts and tells you after. The human doesn't do less work as autonomy rises — they do different work. Steering instead of deciding. Correcting instead of approving. Shaping direction instead of reviewing proposals.

This is why promotion and demotion are explicit, logged events. When you say "good call, just do that next time," you're not automating a task — you're acknowledging that the agent's judgment on this type of decision has earned your trust. When you say "check with me before doing that," you're not adding bureaucracy — you're recalibrating the collaboration because something didn't land.

The goal state isn't L5 everywhere. The goal state is the right level for each type of action, arrived at through real experience rather than default settings. Some actions should stay at L2 forever — not because the agent isn't trusted, but because those decisions genuinely benefit from two perspectives before proceeding.
