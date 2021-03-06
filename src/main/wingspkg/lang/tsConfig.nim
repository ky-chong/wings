# DO NOT MANUALLY EDIT THIS FILE
#
# This file is automatically generated based on the config files located in `examples/input/template/`.

from stones/cases import Case
import tables
import ../lib/tconfig

const COMMENT: string = "//"
const FILENAME: Case = Case.Pascal
const FILETYPE: string = "ts"
const IMPLEMENT_FORMAT: string = "implements {#IMPLEMENT} "
const IMPORT_PATH_FORMAT: string = "{#0}:{#IMPORT}"
const IMPORT_PATH_TYPE: ImportPathType = ImportPathType.Relative
const IMPORT_PATH_PREFIX: string = ""
const IMPORT_PATH_SEPARATOR: char = '/'
const IMPORT_PATH_LEVEL: int = 0
const PARSE_FORMAT: string = "obj.{#VARNAME_JSON}"
const INDENTATION_SPACING: string = "  "

const TEMPLATE_STRUCT: string = """
// #BEGIN_IMPORT
// #IMPORT2 import {#IMPORT_1} from '{#IMPORT_2}';
// #END_IMPORT

// {#COMMENT}
export default class {#NAME_PASCAL} {#IMPLEMENT}{
  [key: string]: any;
// #BEGIN_VAR
  // #VAR public {#VARNAME_CAMEL}: {#TYPE} = {#TYPE_INIT};
// #END_VAR

// #BEGIN_CONSTRUCTOR
  public constructor(obj?: any) {
    if (obj) {
      // #CONSTRUCTOR this.{#VARNAME_CAMEL} = obj.{#VARNAME_JSON} !== undefined && obj.{#VARNAME_JSON} !== null ? {#TYPE_PARSE} : {#TYPE_INIT};
    }
  }
// #END_CONSTRUCTOR

  public toJsonKey(key: string): string {
    switch (key) {
// #BEGIN_JSON
      // #JSON case '{#VARNAME_CAMEL}': {
      // #JSON   return '{#VARNAME_JSON}';
      // #JSON }
// #END_JSON
      default: {
        return key;
      }
    }
  }
// #BEGIN_FUNCTIONS

// #FUNCTIONS {#FUNCTIONS}
// #END_FUNCTIONS
}

"""

const TEMPLATE_ENUM: string = """
enum {#NAME_PASCAL} {
// #BEGIN_VAR
  // #VAR {#VARNAME_PASCAL},
// #END_VAR
}

export default {#NAME_PASCAL};

"""

let TYPES: Table[string, TypeInterpreter] = {
  "dbl": initTypeInterpreter("dbl", "number", "", "0", "obj.{#VARNAME_JSON}"),
  "bool": initTypeInterpreter("bool", "boolean", "", "false", "obj.{#VARNAME_JSON}"),
  "flt": initTypeInterpreter("flt", "number", "", "0", "obj.{#VARNAME_JSON}"),
  "date": initTypeInterpreter("date", "Date", "", "new Date()", "new Date(obj.{#VARNAME_JSON})"),
  "str": initTypeInterpreter("str", "string", "", "''", "obj.{#VARNAME_JSON}"),
  "!imported": initTypeInterpreter("!imported", "{#TYPE_PASCAL}", "", "new {#TYPE_PASCAL}()", "new {#TYPE_PASCAL}(obj.{#VARNAME_JSON})"),
  "int": initTypeInterpreter("int", "number", "", "0", "obj.{#VARNAME_JSON}"),
  "!unimported": initTypeInterpreter("!unimported", "{#TYPE_PASCAL}", "", "new {#TYPE_PASCAL}()", "new {#TYPE_PASCAL}(obj.{#VARNAME_JSON})"),
}.toTable()

let CUSTOM_TYPES: Table[string, CustomTypeInterpreter] = {
  "Map<": interpretType(
    initTypeInterpreter("Map<{TYPE1},{TYPE2}>", "Map<{TYPE1}, {TYPE2}>", "{ parseMap }:wings-ts-util", "new Map<{TYPE1}, {TYPE2}>()", "parseMap<{TYPE2}>(obj.{#VARNAME_JSON})")
  ),
  "[]": interpretType(
    initTypeInterpreter("[]{TYPE}", "{TYPE1}[]", "", "[]", "obj.{#VARNAME_JSON}")
  ),
}.toTable()

let TS_CONFIG*: TConfig = initTConfig(
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
  isp = INDENTATION_SPACING,
  pfmt = PARSE_FORMAT,
  temp = {
    "struct": TEMPLATE_STRUCT,
    "enum": TEMPLATE_ENUM,
  }.toTable(),
  ty = TYPES,
)
