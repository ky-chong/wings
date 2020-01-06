from stones/cases import Case
import tables
import ../lib/tconfig

const COMMENT: string = "#"
const FILENAME: Case = Case.Lower
const FILETYPE: string = "nim"
const IMPLEMENT_FORMAT: string = " of {#IMPLEMENT}"
const IMPORT_PATH_FORMAT: string = "{#IMPORT}"
const IMPORT_PATH_TYPE: ImportPathType = ImportPathType.Relative
const IMPORT_PATH_PREFIX: string = ""
const IMPORT_PATH_SEPARATOR: char = '/'
const IMPORT_PATH_LEVEL: int = 0
const TEMPLATE_STRUCT: string = """
// #BEGIN_IMPORT
import json
// #IMPORT1 import {#IMPORT_1}
// #IMPORT2 from {#IMPORT_1} import {#IMPORT_2}
// #END_IMPORT

// #BEGIN_VAR
type
  {#NAME}* = ref object{#IMPLEMENT}
    ## {#COMMENT}
    // #VAR {#VARNAME_CAMEL}*: {#TYPE}
// #END_VAR
// #BEGIN_FUNCTIONS
  // #FUNCTIONS {#FUNCTIONS}
// #END_FUNCTIONS

"""

const TEMPLATE_ENUM: string = """
// #BEGIN_VAR
type
  {#NAME}* = enum
    // #VAR {#VARNAME_PASCAL}
// #END_VAR

"""

const TYPES: Table[string, string] = {
  "int": "int",
  "flt": "float",
  "dbl": "float",
  "str": "string",
  "bool": "bool",
  "date": "DateTime",
  "!imported": "{#TYPE_PASCAL}",
  "!unimported": "{#TYPE_PASCAL}"
}.toTable()

const CUSTOM_TYPES: Table[string, TypeInterpreter] = {
  "[]": interpretType("[]{TYPE}", "seq[{TYPE1}]"),
  "Map<": interpretType("Map<{TYPE1},{TYPE2}>", "Table[{TYPE1}, {TYPE2}]"),
}.toTable()

let NIM_CONFIG*: TConfig = initTConfig(
  cmt = COMMENT,
  ct = CUSTOM_TYPES,
  c = FILENAME,
  ft = FILETYPE,
  ifmt = IMPLEMENT_FORMAT,
  ipfmt = IMPORT_PATH_FORMAT,
  ipt = IMPORT_PATH_TYPE,
  pfx = IMPORT_PATH_PREFIX,
  sep = IMPORT_PATH_SEPARATOR,
  level = IMPORT_PATH_LEVEL,
  temp = {
    "struct": TEMPLATE_STRUCT,
    "enum": TEMPLATE_ENUM,
  }.toTable(),
  ty = TYPES,
)