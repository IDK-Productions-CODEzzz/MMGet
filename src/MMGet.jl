module MMGet

using Downloads, GZip, MatrixMarket, Random, Tar

export mmget

function mmget(url::String; keep_files::Bool = false, wants_vec_x::Bool = false, wants_vec_b::Bool = false, debug::Bool = false)
    if debug println("Error checking...") end
    
    ## Check for input error
    if !isequal(split(url, ".")[end], "gz")
        error("ERROR: Provided URL suggests downloaded file will not be gzipped. 
            Please provide a MatrixMarket url from MatrixMarket or SuiteSparse Matrix Collection.")
    end
    
    ## Helper functions
    function gz_decompress_create(file_to_decompress, decompress_path)
        
        gz_stream::GZipStream = GZip.open(file_to_decompress)
        data::Vector{UInt8} = read(gz_stream)
        close(gz_stream)
        
        open(decompress_path, "w") do gz_stream
            write(gz_stream, data)
        end # open
        
    end # gz_decompress_create
    
    function process_tar(tar_path, working_dir)
        
        return_A = nothing
        return_x = nothing
        return_b = nothing
        
        tar_stream::IOStream = Tar.open(tar_path)
        rm(tar_path)

        Tar.extract(tar_stream, working_dir)
        tar_directory::String = tar_path[1:end-4] # C:/Users/.../Julia/LnFUy/bcspwr02
 
        matrix_name::String = split(tar_directory, "/")[end]
        
        abstract_file_path::String = tar_directory*"/"*matrix_name # C:/Users/.../Julia/LnFUy/bcspwr02/bcspwr02
        
        if isfile(abstract_file_path*".mtx")
            return_A = MatrixMarket.mmread(abstract_file_path*".mtx")
        else
            error("ERROR: Unpredicted format! 
                Please use URLs from MatrixMarket or SuiteSparse Matrix Collection!")
        end
        
        if isfile(abstract_file_path*"_x.mtx") && wants_vec_x
            return_x = MatrixMarket.mmread(abstract_file_path*"_x.mtx")
        elseif wants_vec_x
            println("WARNING: No vector x available!")
        end
        if isfile(abstract_file_path*"_b.mtx") && wants_vec_b
            return_b = MatrixMarket.mmread(abstract_file_path*"_b.mtx")
        elseif wants_vec_b
            println("WARNING: No vector b available!")
        end
        
        return return_A, return_x, return_b
        
    end # process_tar
    
    function setup_dir()
        
        tmp_name::String = ""
    
        i::Int = 5    
        while true
            
            to_return = pwd()*"/"*Random.randstring(i) # Create random directory name
            if !isdir(to_return)
                mkdir(to_return)
                return to_return
            end # if
            
            i = i + 1
            
        end # while
        
    end # setupDir
    
    ## Initializations
    if debug println("Initializing...") end
    A_matrix = nothing
    x_vector = nothing
    b_vector = nothing
    working_dir::String = setup_dir()
    file_name::String = split(url, "/")[end] # matrix_name.[mtx, tar].gz
    file_path::String = working_dir*"/"*file_name
    decompressed_file_name::String = file_name[1:end-3] # matrix_name.[mtx, tar]
    decompressed_file_path::String = file_path[1:end-3]
    
    ## Download temporary file
    if debug println("Downloading...") end
    Downloads.download(url, file_path)
    
    ## Decompress .gz
    if debug println("Decompressing...") end
    gz_decompress_create(file_path, decompressed_file_path)
    rm(file_path)
    
    ## Read matrix / matrices
    if debug println("Reading matrix / matrices...") end
    if isequal(decompressed_file_name[end-2:end], "tar") # If filename ends in ".tar"
        A_matrix, x_vector, b_vector = process_tar(decompressed_file_path, working_dir)
    else # Assuming filename ends in ".mtx"
        if wants_vec_x
            println("WARNING: No vector x available!")
        end
        if wants_vec_b
            println("WARNING: No vector b available!")
        end
        A_matrix = MatrixMarket.mmread(decompressed_file_path)
    end # if
    
    ## Clean if applicable
    if !keep_files
        if debug println("Removing files...") end
        rm(working_dir, recursive = true)
    else
        println(working_dir)
    end
    
    ## Return A after deciding to clean; may return more than A (ie A, x, b from Ax=b)
    if isequal(x_vector, nothing) && isequal(b_vector, nothing)
        if debug println("Returning matrix A...") end
        return A_matrix
    elseif isequal(x_vector, nothing)
        if debug println("Returning matrix A and vector b...") end
        return A_matrix, b_vector
    elseif isequal(b_vector, nothing)
        if debug println("Returning matrix A and vector x...") end
        return A_matrix, x_vector
    else
        if debug println("Returning matrix A and vectors x and b...") end
        return A_matrix, x_vector, b_vector
    end # if
    
end # mmget

end # module