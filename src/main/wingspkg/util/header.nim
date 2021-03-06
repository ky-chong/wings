from strutils import indent, split

proc genHeader*(prefix: string, source: string, text: string): string =
  ## Returns a string of a header (indented by given `prefix`).
  result &= text & "\nSource: " & source

  let lines: seq[string] = result.split("\n")
  result = ""
  for line in lines:
    if line.len() > 0:
      result &= prefix & " " & line & "\n"
    else:
      result &= prefix & "\n"
