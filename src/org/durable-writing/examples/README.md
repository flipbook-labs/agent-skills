# Worked examples: slimming a PR body

Two real changes, each walked from an agent's default PR body down to a slim, template-fitted final. In both, the diff never changed between drafts, only the prose did. Read the drafts in order and watch what gets cut, and why.

| Example                                 | The change                        | What it adds                                                                                                                                                                                   |
| --------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`workflow-pr/`](workflow-pr/README.md) | A GitHub Actions workflow edit    | Whys that are technical (an app token, a commit-on-top decision, a secret dependency), and why the deepest cut comes from a pass not attached to the words it is cutting                       |
| [`skills-pr/`](skills-pr/README.md)     | Adding two skills to this library | A docs-only change where almost everything is derivable from the diff, so the honest body is short and one scope judgment is all that survives. It also catches a note that had already rotted |

The two are complementary. The workflow example shows the mechanics of cutting when a change carries real technical decisions, and makes the case for generating in one context and cutting in another. The skills example shows the opposite extreme, a documentation change where the diff already says almost everything, and where the fill-the-body instinct is the whole risk.
