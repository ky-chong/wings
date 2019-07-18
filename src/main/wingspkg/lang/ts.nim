from strutils
import contains, indent, intToStr, split

proc types(name: string): string =
    if contains(name, "[]"):
        return "[]"

    case name
    of "int":
        result = "number"
    of "str":
        result = "string"
    of "bool":
        result = "boolean"
    of "date":
        result = "Date"
    else:
        result = name

proc typeInit(name: string): string =
    if contains(name, "[]"):
        return "[]"

    case name
    of "int":
        result = "-1"
    of "str":
        result = "''"
    of "bool":
        result = "false"
    of "date":
        result = "new Date()"
    else:
        result = "new " & name & "()"

proc typeAssign(name: string, content: string): string =
    case name
    of "date":
        result = "new Date(" & content & ")"
    else:
        result = content

proc enumFile*(
    name: string,
    values: seq[string],
): string =
    result = "enum " & name & "{"
    
    var content: string = ""
    for value in values:
        if value.len() > 0:
            content &= "\n" & value & ","

    result &= indent(content, 4, " ") & "\n}\n"
    result &= "\nexport default " & name & ";\n"


proc structFile*(
    name: string,
    imports: seq[string],
    fields: seq[string],
    functions: string,
    implement: string,
): string =
    result = ""

    for toImport in imports:
        if toImport.len < 1:
            continue

        var importDat: seq[string] = toImport.split(':')

        result &= "import " & importDat[0] & " from '" & importDat[1] & "';\n"

    result &= "\n"
    result &= "export default class " & name

    if implement.len() > 0:
        result &= " implements " & implement

    result &= " {\n"

    var declaration: string = "[key: string]: any;"
    var init: string = ""
    var jsonKey: string = ""

    for fieldStr in fields:
        let field = fieldStr.split(' ')
        if field.len() < 3:
            continue
        
        if (declaration.len() > 1):
            declaration &= "\n"

        if (init.len() > 1):
            init &= "\n"
            jsonKey &= "\n"

        var typeInit: string = typeInit(field[1])
        if field.len() > 3:
            typeInit = field[3]

        declaration &= "public " & field[0] & ": " & types(field[1]) & " = " & typeInit & ";"

        if contains(field[1], "[]"):
            init &= "\nif (data." & field[2] & " !== \"null\") {\n"
            init &= indent("this." & field[0] & " = " & typeAssign(field[1], "data." & field[2]) & ";", 4, " ")
            init &= "\n}"
        else:
            init &= "this." & field[0] & " = " & typeAssign(field[1], "data." & field[2]) & ";"
        
        jsonKey &= "case '" & field[0] & "': {\n"
        jsonKey &= indent("return '" & field[2] & "';", 4, " ")
        jsonKey &= "\n}"

    result &= indent(declaration, 4, " ")
    result &= "\n"
    result &= indent(
        "\npublic init(data: any): boolean {\n" &
        indent(
            "try {\n" &
            indent(init, 4, " ") &
            "\n} catch (e) {\n" &
            indent("return false;", 4, " ") &
            "\n}\nreturn true;", 4, " "
        ) &
        "\n}", 4, " "
    )
    result &= "\n"
    result &= indent(
        "\npublic toJsonKey(key: string): string {\n" &
        indent(
            "switch (key) {\n" &
            indent(jsonKey, 4, " ") &
            "\n" &
            indent(
                "default: {\n" &
                indent("return key;", 4, " ") &
                "\n}", 4, " "
            ) & "\n}", 4, " "
        ) & "\n}", 4, " "
    )

    if functions.len() > 0:
        result &= "\n" & functions

    result &= "\n}\n"
