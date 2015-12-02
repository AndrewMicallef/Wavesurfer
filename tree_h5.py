import h5py
import sys

def tree(f, prefix = ""):
    prefix = f.name
    
    for k in f:
        
        try:
            tree(f[k], prefix = prefix + "--")
        except:
            if type(f[k]) == h5py._hl.dataset.Dataset:
                print prefix, k

if __name__ == "__main__":
    
    f = h5py.File(sys.argv[1], 'r')

    tree(f)