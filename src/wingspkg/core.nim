from strutils
import capitalizeAscii, contains, join, normalize, parseEnum, removeSuffix, split, splitWhitespace
import tables
import lang/go, lang/ts, lang/kt

const filetypes: Table[string, int] =
    toTable([
        ("go", 0),
        ("kt", 1),
        ("ts", 2),
    ])

proc structFile(file: File, filename: string, package: Table[string, string]): Table[string, string] =
    var line: string = ""

    var inStruct: bool = false
    var inFunc: string = ""

    var name: string = ""
    var functions, implement: Table[string, string] = initTable[string, string]()
    var fields, genImports: seq[string] = newSeq[string](0)
    var imports: Table[string, seq[string]] = initTable[string, seq[string]]()

    while readLine(file, line):
        if line.len() < 1:
            if inFunc != "":
                functions[inFunc] &= "\n"

            continue;

        var words: seq[string] = line.splitWhitespace()

        if not inStruct and inFunc == "":
            if words[0] == "import":
                genImports.add(words[1])
            elif words[0].contains("implement"):
                var toImplement: string = words[1]
                words = words[0].split('-')
                implement.add(words[0], toImplement)
            elif words[0].contains("-import"):
                words[0].removeSuffix("-import")
                if not imports.hasKey(words[0]):
                    imports.add(words[0], newSeq[string](0))
                imports[words[0]].add(words[1])
            elif words[0].contains("Func("):
                words[0].removeSuffix("Func(")
                functions.add(words[0], "")
                inFunc = words[0]
            elif words.len > 1 and words[1] == "{":
                name = words[0]
                inStruct = true
        elif inStruct:
            if words[0] == "}":
                inStruct = false
            else:
                fields.add(join(words, " "))
        elif inFunc != "":
            if words.len() > 0 and words[0] == ")":
                inFunc = ""
            else:
                functions[inFunc] &= "\n" & line

    var structFiles: Table[string, string] = initTable[string, string]()

    for filetype in package.keys:
        var fileContent: string = ""
        var tempPackage: seq[string] = split(package[filetype], '/')
        case filetype
        of "go":
            fileContent = go.structFile(
                name, imports.getOrDefault(filetype),
                fields, functions.getOrDefault(filetype),
                tempPackage[tempPackage.len() - 1],
            )
        of "kt":
            fileContent = kt.structFile(
                name, imports.getOrDefault(filetype),
                fields, functions.getOrDefault(filetype),
                implement.getOrDefault(filetype), tempPackage[tempPackage.len() - 1],
            )
        of "ts":
            fileContent = ts.structFile(
                name, imports.getOrDefault(filetype),
                fields, functions.getOrDefault(filetype),
                implement.getOrDefault(filetype),
            )
        else:
            continue

        structFiles.add(filetype, fileContent)

    return structFiles

proc enumFile(file: File, filename: string, package: Table[string, string]): Table[string, string] =
    var line: string = ""
    var name: string = ""

    var inEnum: bool = false
    var values: seq[string] = newSeq[string]()

    while readLine(file, line):
        if line.len() < 1:
            continue;

        var words: seq[string] = line.splitWhitespace()

        if not inEnum and words.len > 1 and words[1] == "{":
            name = words[0]
            inEnum = true
        elif words[0] == "}":
            inEnum = false
        elif inEnum:
            values.add(words[0])

    var enumFiles: Table[string, string] = initTable[string, string]()

    for filetype in package.keys:
        var fileContent: string = ""
        var tempPackage: seq[string] = split(package[filetype], '/')
        case filetype
        of "go":
            fileContent = go.enumFile(name, values, tempPackage[tempPackage.len() - 1])
        of "kt":
            fileContent = kt.enumFile(name, values, tempPackage[tempPackage.len() - 1])
        of "ts":
            fileContent = ts.enumFile(name, values)
        else:
            continue

        enumFiles.add(filetype, fileContent)

    return enumFiles

proc newFileName(filename: string): Table[string, string] =
    let temp: seq[string] = filename.split('/')
    var filenames: Table[string, string] = initTable[string, string]()

    for filetype in filetypes.keys:
        case filetype
        of "go":
            filenames.add(
                filetype,
                join(
                    split(
                        temp[temp.len() - 1], '_'
                    )
                )
            )
        of "kt", "ts":
            var words = split(temp[temp.len() - 1], '_')
            for i in countup(0, words.len() - 1, 1):
                words[i] = capitalizeAscii(words[i])
            filenames.add(filetype, join(words))

    return filenames

proc fromFile*(filename: string): Table[string, string] =
    var fileInfo: seq[string] = filename.split('.')

    var newFileName: Table[string, string] = initTable[string, string]()
    var fileContents: Table[string, string] = initTable[string, string]()
    var packages: Table[string, string] = initTable[string, string]()

    let file: File = open(filename)
    var line: string

    while readLine(file, line) and line.len() > 0:
        var words: seq[string] = line.splitWhitespace()
        var filepath: seq[string] = words[0].split('-')

        if words.len() < 2 or filepath.len() < 2:
            continue

        if filepath[1] != "filepath":
            break;

        packages.add(filepath[0], words[1])

    case fileInfo[fileInfo.len() - 1]
    of "struct":
        fileContents = structFile(file, filename, packages)
        newFileName = newFileName(filename.substr(0, filename.len() - 7))
    of "enum":
        fileContents = enumFile(file, filename, packages)
        newFileName = newFileName(filename.substr(0, filename.len() - 5))
    else:
        echo "Unsupported file type: " & fileInfo[fileInfo.len() - 1]
        file.close()
        return

    file.close()

    var generatedFiles: Table[string, string] = initTable[string, string]()

    for filetype in packages.keys:
        generatedFiles.add(
            getOrDefault(packages, filetype) &
            "/" &
            newFileName[filetype] &
            filetype,
            getOrDefault(fileContents, filetype)
        )

    return generatedFiles
