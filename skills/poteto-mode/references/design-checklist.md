# Design checklist

Rules for the rendered page that agents miss and Emil's skills leave out. Read it before you write UI code. Before you call UI work done, render every state the change can reach, and hold each one to every item below.

## Browser defaults

Replace each of these browser defaults with a choice from the page's own palette and type:

- `::selection` and `caret-color`.
- A visible `:focus-visible` ring on every focusable element, links included.
- `text-underline-offset` on underlined links.
- `text-wrap: balance` on headings and `text-wrap: pretty` on paragraphs.
- `font-variant-numeric: tabular-nums` on numbers that line up, such as amounts, totals, and counts in tables and lists.

## States

- **Empty.** Say what will appear here and how the user gets the first one, and offer that action when the page has it. "Searches you save appear here. Save one from any results page." tells the user more than "No saved searches."
- **Error.** Name what failed in the user's words, keep what they typed, and give the next step. Raw server text and status codes go to the console.

## Look at it

Screenshot each state and open every screenshot: loaded, loading, empty, error, and after each action. Confirm that every element marked `hidden` or closed is absent from the screenshot, because a CSS `display` value overrides the `hidden` attribute.

Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus, Apache-2.0.
