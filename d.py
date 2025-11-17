import os
import json
import subprocess
import shutil


proj_header_dict = {"coq-stdlib" : "Coq",
                    "coq-unicoq" : "Unicoq", 
                    "stdpp-coq-stdpp": "stdpp",
                    "coq-ext-lib" : "ExtLib",
                    "hierarchy-builder" : "HB",
                    "mathcomp-ssreflect" : "mathcomp.ssreflect",
                    "mathcomp-algebra": "mathcomp.algebra",
                    "mathcomp-fingroup" : "mathcomp.fingroup",
                    "mathcomp-character" : "mathcomp.character",
                    "mathcomp-field": "mathcomp.field",
                    "mathcomp-solvable" : "mathcomp.solvable",
                    "bigenough" : "mathcomp.bigenough",
                    "bignums" : "Bignums",
                    "coqeal" : "CoqEAL",
                    "coqprime":"Coqprime",
                    "coq-paramcoq":"Param",
                    "real-closed":"mathcomp.real_closed",
                    "coq-equations":"Equations",
                    "finmap":"mathcomp.finmap",
                    "analysis":"mathcomp.analysis",
                    "coquelicot":"Coquelicot",
                    "flocq":"Flocq",
                    "coq-gappa":"Gappa",
                    "interval":"Interval",
                    "iris":"iris",
                    "Cdcl":"Cdcl",
                    "LibHyps":"LibHyps",
                    "multinomials":"mathcomp.multinomials",
                    "menhir":"MenhirLib",
                    "AAC_tactics":"AAC_tactics",
                    "algebra-tactics":"mathcomp.algebra_tactics",
                    "MathClasses":"MathClasses",
                    "coq-corn" : "CoRN",
                    "mtac":"Mtac2",
                    "coq-relation-algebra":"RelationAlgebra",
                    "reglang":"RegLang",
                    "coq-simple-io":"SimpleIO",
                    "QuickChick":"QuickChick",
                    "coq-hott":"HoTT",
                    "compcert":"compcert",
                    "vst":"VST",
                    "coq-fcsl-pcm": "pcm",
                    "coq-htt": "htt"
                    }

output_name = {
  "AAC_tactics": "coq-aac-tactics",
  "compcert": "compcert",
  "coq-hott": "coq-hott",
  "coquelicot": "coq-coquelicot",
  "LibHyps": None,
  "mathcomp-solvable": "mathcomp-solvable",
  "real-closed": "mathcomp-real-closed",
  "algebra-tactics": "mathcomp-algebra-tactics",
  "coq-corn": "coq-corn",
  "coq-paramcoq": None,
  "coq-unicoq": None,
  "MathClasses": "coq-math-classes",
  "mathcomp-ssreflect": "mathcomp-ssreflect",
  "reglang": "coq-reglang",
  "analysis": "mathcomp-analysis",
  "coqeal": "coq-coqeal",
  "coqprime": "coq-coqprime",
  "finmap": "mathcomp-finmap",
  "mathcomp-algebra": "mathcomp-algebra",
  "menhir": None,
  "stdpp-coq-stdpp": "coq-stdpp",
  "bigenough": "mathcomp-bigenough",
  "coq-equations": "coq-equations",
  "coq-relation-algebra": "coq-relation-algebra",
  "flocq": "coq-flocq",
  "mathcomp-character": "mathcomp-character",
  "mtac": "coq-mtac2",
  "vst": "coq-vst",
  "bignums": "coq-bignums",
  "coq-ext-lib": "coq-ext-lib",
  "coq-simple-io": None,
  "interval": "coq-interval",
  "mathcomp-field": "mathcomp-field",
  "multinomials": "mathcomp-multinomials",
  "Cdcl": "coq-itauto",
  "coq-gappa": "coq-gappa",
  "coq-stdlib": "coq-stdlib",
  "iris": "coq-iris",
  "mathcomp-fingroup": "mathcomp-fingroup",
  "QuickChick": "coq-quickchick",
  "coq-fcsl-pcm" : "coq-fcsl-pcm",
  "coq-htt": "coq-htt"
}

def get_files_recursive(directory, suff):
    fileslist = []
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(suff) and not filename.startswith('.'):
                fileslist.append(os.path.join(dirpath, filename))
    return fileslist


def run_subprocess(cmd, file):
    work = subprocess.Popen([
        cmd,
        file
    ], stdout=subprocess.PIPE)

    while True:
        output = work.stdout.readline().rstrip().decode('utf-8')
        if output == '' and work.poll() is not None:
            break
        if output:
            print(output.strip())

    subprocess.Popen.wait(work)

    recode = work.returncode
    out = str(work.stdout.read(), "UTF-8")

    err = ""
    # err = str(work.stderr.read(), "UTF-8")
    return recode, out, err

def build_project(benchmark_path, cur_path, projectname):
    mathcomp_proj = ["mathcomp-ssreflect", "mathcomp-algebra", "mathcomp-fingroup", "mathcomp-character", "mathcomp-field", "mathcomp-solvable"]

    if os.path.exists("/home/opam/data/rocqjson"):
        shutil.rmtree('/home/opam/data/rocqjson', ignore_errors=True)
        os.mkdir("/home/opam/data/rocqjson")
    else:
        os.mkdir("/home/opam/data/rocqjson")

    if projectname in mathcomp_proj:
        projectname = "math-comp-mathcomp"

    os.chdir(benchmark_path)
    os.system("make " + projectname)
    os.chdir(cur_path)

def merge_all(dirpath, PROJNAME):
    l = get_files_recursive(dirpath, ".json")
    res = []
    for f in l:
        print(f)
        fd = open(f, 'r')
        d = fd.read()
        fd.close()
        if d == "":
            continue
        j = json.loads(d)

        filename = j["filename"]
        fullpath = j["fullpath"]
        decl = j['decl']
        newdecl = []
        for i in range(len(decl)):
            kind = decl[i]["kind"]
            if kind == "VernacAbort":
                newdecl.pop()
            else:
                newdecl.append(decl[i])

        res.append({"filename": filename, "fullpath": fullpath, "decl": newdecl})

    print("out file: " + "./parser_json/" + PROJNAME + "_all.json")
    fd = open("./parser_json/" + PROJNAME + "_all.json", 'w')
    fd.write(json.dumps(res, indent=4))
    fd.close()

def find_from_env(xlemmaname, envjson):
    for x in envjson:
        lemmaname = x['lemmaname']
        if lemmaname == xlemmaname:
            return x
    return None


def ali_name(MODULENAME, fullpath, scope, idname):
    if "ExtLib" == MODULENAME or "Coq" == MODULENAME:
        if "theories." in fullpath:
            p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
            p_lemmaname = p_lemmaname.replace("theories.", "")
        else:
            p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "stdpp" == MODULENAME:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
        
        if "stdpp_bitvector." in p_lemmaname:
            p_lemmaname = p_lemmaname.replace("stdpp_bitvector.", "")
        elif "stdpp_unstable." in p_lemmaname:
            p_lemmaname = p_lemmaname.replace("stdpp_unstable.", "")
        else:
            p_lemmaname = p_lemmaname[len("stdpp."):]
    elif "HB" == MODULENAME:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
        p_lemmaname = p_lemmaname.replace("HB.HB.", "HB.")
    elif "mathcomp" in MODULENAME:
        if MODULENAME == "mathcomp.ssreflect":
            if "ssreflect." not in fullpath:
                return None
        elif MODULENAME == "mathcomp.algebra":
            if "algebra." not in fullpath:
                return None
        elif MODULENAME == "mathcomp.fingroup":
            if "fingroup." not in fullpath:
                return None
        elif MODULENAME == "mathcomp.character":
            if "character." not in fullpath:
                return None
        elif MODULENAME == "mathcomp.field":
            if "field." not in fullpath:
                return None
        elif MODULENAME == "mathcomp.solvable":
            if "solvable." not in fullpath:
                return None
        elif MODULENAME == "mathcomp.real_closed":
            fullpath = fullpath.replace("theories.", "")
            p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
            return p_lemmaname
        elif MODULENAME == "mathcomp.analysis":
            fullpath = fullpath.replace("theories.", "")
            p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
            return p_lemmaname
        elif MODULENAME == "mathcomp.multinomials":
            fullpath = fullpath.replace("src.", "")
            p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
            return p_lemmaname
        elif MODULENAME == "mathcomp.algebra_tactics":
            fullpath = fullpath.replace("theories.", "")
            p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
            return p_lemmaname
        elif MODULENAME == "mathcomp.bigenough":
            if "bigenough" not in fullpath:
                return None
            else:
                p_lemmaname = MODULENAME  + "." + fullpath + "." + scope + idname
                return p_lemmaname
        elif MODULENAME == "mathcomp.finmap":
            p_lemmaname = MODULENAME  + "." + fullpath + "." + scope + idname
            return p_lemmaname
            
        p_lemmaname = "mathcomp" + "." + fullpath + "." + scope + idname
    elif "Coqprime" == MODULENAME:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
        p_lemmaname = p_lemmaname.replace("Coqprime.src.", "")
    elif "CoqEAL" == MODULENAME:
        # fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "Equations" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "Coquelicot" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "Flocq" == MODULENAME:
        fullpath = fullpath.replace("src.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "Gappa" == MODULENAME:
        fullpath = fullpath.replace("src.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "Interval" == MODULENAME:
        fullpath = fullpath.replace("src.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "iris" == MODULENAME:
        if "iris." in fullpath:
            fullpath = fullpath.replace("iris.","")
        elif "iris_unstable." in fullpath:
            fullpath = fullpath.replace("iris_unstable.", "unstable.")
        elif "iris_deprecated." in fullpath:
            fullpath = fullpath.replace("iris_deprecated.", "deprecated.")
        elif "iris_heap_lang." in fullpath:
            fullpath = fullpath.replace("iris_heap_lang.", "heap_lang.")
        else:
            pass
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "Cdcl" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "LibHyps" == MODULENAME:
        fullpath = fullpath.replace("LibHyps.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "MenhirLib" == MODULENAME:
        fullpath = fullpath.replace("src.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "AAC_tactics" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "MathClasses" == MODULENAME:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "CoRN" == MODULENAME:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "Mtac2" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "RelationAlgebra" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "RegLang" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "SimpleIO" == MODULENAME:
        fullpath = fullpath.replace("src.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "QuickChick" == MODULENAME:
        fullpath = fullpath.replace("src.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "HoTT" == MODULENAME:
        fullpath = fullpath.replace("theories.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "compcert" == MODULENAME:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "VST" == MODULENAME:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    elif "htt" == MODULENAME:
        fullpath = fullpath.replace("htt.", "")
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
    else:
        p_lemmaname = MODULENAME + "." + fullpath + "." + scope + idname
        
        
    print(p_lemmaname)
    return p_lemmaname

def insert_to_parser(pjsonpath, rjsonpath, PROJNAME):
    f1 = open(pjsonpath, 'r')
    f2 = open(rjsonpath, 'r')
    datap = json.load(f1)
    datar = json.load(f2)
    f1.close()
    f2.close()
    sum = 0
    
    MODULENAME = proj_header_dict[PROJNAME]

    res = []
    for x in datap:
        filename = x['filename']
        fullpath = x["fullpath"]
        fullpath = fullpath.replace("./", "")
        fullpath = fullpath[:-2].replace("/", ".")
        decl = x['decl']

        for d in range(len(decl)):
            idname = decl[d]["idname"]
            kind = decl[d]["kind"]
            line = decl[d]["line"]
            content = decl[d]["content"]
            scope = decl[d]["scope"]

            if kind == "VernacFixpoint" or kind == "VernacDefinition":
                pobj = decl[d]
                pobj.update({"filename": filename, "fullpath": fullpath})

                print(MODULENAME)
                p_lemmaname = ali_name(MODULENAME, fullpath, scope, idname)
                if p_lemmaname == None:
                    continue
                print(p_lemmaname)

                sum += 1

                eobj = find_from_env(p_lemmaname, datar)
                if eobj == None:
                    continue
                    # res.append(pobj)
                else:
                    pobj.update(eobj)
                    res.append(pobj)


    print("sum: " + str(sum))
    print(len(res))
    
    outname = output_name[PROJNAME]
    if outname == None:
        return
    
    
    # f = open("./" + PROJNAME + "_merge_all.json", 'w')
    f = open("./data_def_json/" + outname + ".json", 'w')
    f.write(json.dumps(res, indent=4))
    f.close()

def get_coq_files(proj, l):
    res = []

    if proj == "Coq":
        proj = "coq"

    for f in l:
        fl = f.split('/')
        fl[-1] = fl[-1].replace('.vo', '.')
        h = ".".join(fl[fl.index(proj) + 1:])

        if proj == "theories":
            header_proj = "Coq."
        else:
            header_proj = "From " + proj + " Require Import "

        h = header_proj + h[:-1] + ".\n"
        res.append(h)

    return res

def header_to_file(PROJNAME, install_path, modulename):
    header = []
    dict = {}
    code = ""

    if PROJNAME == "multinomials":
        install_path = os.path.join(install_path, "mathcomp", PROJNAME)


    l = get_files_recursive(install_path, ".vo")
    header += get_coq_files(modulename, l)

    for i in header:
        if i == "mathcomp.all_ssreflect":
            dict[i] = "From mathcomp Require Import all_ssreflect."
        elif i == "mathcomp.all_algebra":
            dict[i] = "From mathcomp Require Import all_algebra."
        elif i == "mathcomp.all_fingroup":
            dict[i] = "From mathcomp Require Import all_fingroup."

    for i in header:
        code += i

    code += "\nFrom Lemmas Require Import Loader.\n Createdb."
    fd = open("./headers/"+ PROJNAME.replace("-", "_") +".v", "w")
    fd.write(code)
    fd.close()

def getdetail(PROJNAME):

    detailname = output_name[PROJNAME]

    f = open("./data_def_json/" + detailname + ".json")
    data = json.load(f)
    f.close()

    code = ""
    newjson = []
    newdict = {}
    for x in data:
        lemmaname = x["lemmaname"]
        linenum = x["line"]
        usedfunction = x["usedfunction"]
        ind_info = x["ind_info"]
        fullpath = x["fullpath"]
        deftype = x["Type"]
        indnamelist = []

        for y in ind_info:
            if y == None:
                continue
            for z in y:
                indname = z["indinfo"]["indname"]
                indnamelist.append(indname)
        indnamelist = list(set(indnamelist))

        newdict[lemmaname] = {"linenum":linenum, "usedfunction" : usedfunction, "indnamelist":indnamelist, "fullpath": fullpath, "type": deftype}


    outname = output_name[PROJNAME]
    if outname == None:
        return
    
    f = open('./detail-def/' + outname + '.json', 'w')
    f.write(json.dumps(newdict, indent=4))
    f.close()

def jsontotxt(PROJNAME):

    textname = output_name[PROJNAME]

    f = open('./data_def_json/' + textname + '.json', 'r')
    data = json.load(f)
    f.close()

    code = ""
    for x in data:
        lemmaname = x["lemmaname"]
        typ = x["Type"]
        content = x["content"]

        typ = typ.replace("\n", "")
        content = content.replace("\n", "")

        code += lemmaname + " : " + content + "\n"


    outname = output_name[PROJNAME]
    if outname == None:
        return
    
    f = open('./text-def/' + outname + '.txt', 'w')
    f.write(code)
    f.close()


def init_dir(JSONFILE_PATH, env_json_path, detail_path, data_json_path, parser_json_pat, text_path):
    if not os.path.exists(JSONFILE_PATH):
        os.mkdir(JSONFILE_PATH)

    if not os.path.exists(env_json_path):
        os.mkdir(env_json_path)
    
    if not os.path.exists(detail_path):
        os.mkdir(detail_path)
    
    if not os.path.exists(data_json_path):
        os.mkdir(data_json_path)

    if not os.path.exists(parser_json_pat):
        os.mkdir(parser_json_pat)

    if not os.path.exists(text_path):
        os.mkdir(text_path)


def start_ext(PROJNAME):
    JSONFILE_PATH = "/home/opam/data/rocqjson"
    install_path = "/home/opam/.opam/lemmaextraction/lib/coq/user-contrib"
    benchmark_path = "/home/opam/data/lemmasearch_proj_extraction//"
     
    env_json_path = "/home/opam/data/env_json"
    parser_json_path = "/home/opam/data/parser_json/"

    data_json_path = "/home/opam/data/data_def_json/"
    detail_path = "/home/opam/data/detail-def/"
    text_path = "/home/opam/data/text-def/"

    init_dir(JSONFILE_PATH, env_json_path, detail_path, data_json_path, parser_json_path, text_path)

    insert_to_parser("./parser_json/" + PROJNAME+"_all.json", os.path.join(env_json_path, PROJNAME.replace("-", "_")+"_env.json" ), PROJNAME)
    getdetail(PROJNAME)
    jsontotxt(PROJNAME)


start_ext("coq-stdlib")
start_ext("stdpp-coq-stdpp")
start_ext("coq-ext-lib")
start_ext("mathcomp-ssreflect")
start_ext("mathcomp-algebra")
start_ext("mathcomp-fingroup")
start_ext("mathcomp-character")
start_ext("mathcomp-field")
start_ext("mathcomp-solvable")
start_ext("bigenough")
start_ext("bignums")
start_ext("coqeal")
start_ext("coqprime")
start_ext("real-closed")
start_ext("multinomials")
start_ext("coq-equations")
start_ext("finmap")
start_ext("analysis")
start_ext("coquelicot")
start_ext("flocq")
start_ext("coq-gappa")
start_ext("interval")
start_ext("iris",)
start_ext("Cdcl")
start_ext("multinomials")
start_ext("AAC_tactics")
start_ext("algebra-tactics")
start_ext("MathClasses")
start_ext("coq-corn")
start_ext("mtac")
start_ext("coq-relation-algebra")
start_ext("reglang")
start_ext("QuickChick")
start_ext("coq-hott")
start_ext("compcert")
start_ext("vst")
start_ext("coq-fcsl-pcm")
start_ext("coq-htt")