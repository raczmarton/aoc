import strutils
import std/parseutils
import std/sequtils

type Equation* = object
  value: int
  parts: seq[int]

let content = readFile("input")
let lines = content.split("\n")
var equations: seq[Equation] = @[]

for line in lines:
  let parts = line.split(": ")
  echo line
  try:
    let value = parseInt(parts[0])
    let ps = parts[1].split(" ").mapIt(parseInt(it))
    equations.add(Equation(value: value, parts: ps))
  except ValueError:
    echo "Error: ", line.len, parts

proc checkEquation(eq: Equation, current: int, index: int, part2: bool): bool =
  if index == eq.parts.len:
    return current == eq.value
  else:
    return (checkEquation(eq, current + eq.parts[index], index + 1, part2) or
            checkEquation(eq, current * eq.parts[index], index + 1, part2) or(
              part2 and checkEquation(eq, parseInt($current & $eq.parts[index]), index + 1, part2)
            ))


proc run(part2: bool) =
  var result = 0
  for eq in equations:
    if checkEquation(eq, 0, 0, part2):
      result += eq.value
  echo result

run(false)
run(true)
