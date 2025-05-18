# MMGet
Julia Package to get a MatrixMarket matrix directly from MatrixMarket or SuiteSparse Matrix Collection.


## Expected use ##
Expected to pull from https://math.nist.gov/MatrixMarket/ or http://sparse.tamu.edu subdomains.

An example of a good MatrixMarket URL: https://math.nist.gov/pub/MatrixMarket2/Harwell-Boeing/bcsstruc1/bcsstk01.mtx.gz

An example of a good SuiteSparse Matrix Collection URL: https://suitesparse-collection-website.herokuapp.com/MM/AG-Monien/netz4504.tar.gz


## Usage ##
`mmget(url::String; keep_files::Bool = false, wants_vec_x::Bool = false, wants_vec_b::Bool = false, debug::Bool = false)`

`url`: URL link address.

`keep_files`: If true, does not delete downloaded files from working directory.

`wants_vec_x`: If true, will attempt to output a vector x if in the downloaded .tar.gz from SuiteSparse Matrix Collection.

`wants_vec_b`: If true, will attempt to output a vector b if in the downloaded .tar.gz from SuireSparse Matrix Collection.

`debug`: If true, will output where in each step the function currently is.


## Output ##
NOTE: Output is based on the linear algebra problem $Ax=b$.

NOTE: If `wants_vec_x = true` or `wants_vec_b = true` but either vector is not available, will simply not return specific vector. Expected to always return matrix A at minimum.

`wants_vec_x = false && wants_vec_b = false` => `return A`

`wants_vec_x = true && wants_vec_b = false` => `return A, x`

`wants_vec_x = false && wants_vec_b = false` => `return A, b`

`wants_vec_x = false && wants_vec_b = false` => `return A, x, b`


## Example code ##
```jl:
using Pkg
Pkg.add(url="https://github.com/CHLOzzz/MMGet")
using MMGet

A = MMGet.mmget("https://math.nist.gov/pub/MatrixMarket2/Harwell-Boeing/bcsstruc1/bcsstk01.mtx.gz", keep_files = true)
display(A)
```
