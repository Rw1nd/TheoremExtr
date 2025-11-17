import os
import tarfile


def get_files_recursive(dir, suff):
    res = []
    for dirpath, dirnames, filenames in os.walk(dir):
        for filename in filenames:
            if filename.endswith(suff) and not filename.startswith("."):
                res.append(os.path.join(dirpath, filename))

    return res

def count_text(path):
    l = get_files_recursive(path, ".txt")
    sum = 0
    for x in l:
        f = open(x)
        code = f.read()
        f.close()
        count = len(code.split("\n"))-1
        sum = sum + count
    return sum

def main():
    lemmasum = count_text("/home/abc/work/FM26_tool/OCaml-Dockerfile/text")
    defsum = count_text("/home/abc/work/FM26_tool/OCaml-Dockerfile/text-def")
    print("Number of lemmas: ", lemmasum)
    print("Number of definitions: ", defsum)

if __name__ == "__main__":
    main()