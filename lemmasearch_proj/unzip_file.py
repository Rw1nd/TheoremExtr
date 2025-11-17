import os
import tarfile


def get_files_recursive(dir, suff):
    res = []
    for dirpath, dirnames, filenames in os.walk(dir):
        for filename in filenames:
            if filename.endswith(suff) and not filename.startswith("."):
                res.append(os.path.join(dirpath, filename))

    return res


def unzip_tar_file(path, suff):
    l = get_files_recursive(path, suff)
    for x in l:
        os.system("tar zxvf " + x)


unzip_tar_file("/home/opam/data/lemmasearch_proj", "tar.gz")
os.system("unzip  " +  "v1.6-8.20.zip")