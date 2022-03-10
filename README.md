[![Tests](https://github.com/GTorlai/Observers.jl/workflows/Tests/badge.svg)](https://github.com/GTorlai/Observers.jl/actions?query=workflow%3ATests)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# Observers.jl

The Observers.jl package provides functionalities to record and track metrics of interest during the iterative evaluation
of a given function. It may be used to monitor convergence of optimization algorithms, to measure revelant observables in
in numerical simulations (e.g. condensed matter physics, quantum simulation, quantum chemistry etc).

## Basic Usage

```julia
using Observers

# Series for π/4
f(k) = (-1)^(k+1)/(2k-1)

function my_iterative_function(niter; observer!, observe_step)
  π_approx = 0.0
  for n in 1:niter
    π_approx += f(n)
    if iszero(n % observe_step)
      update!(observer!; π_approx = 4π_approx, iteration = n)
    end
  end
  return 4π_approx
end

# Measure the relative error from π at each iteration
err_from_π(; π_approx) = abs(π - π_approx) / π

# Record which iteration we are at
iteration(; iteration) = iteration

obs = Observer(err_from_π, iteration)

niter = 10000
```

Now we run the function and analyze the results:
```julia
julia> π_approx = my_iterative_function(niter; observer! = obs, observe_step = 1000)
3.1414926535900345
```

The `results` function is the primary way to obtain the results of the function you passed at each iteration. Calling `results` on an `Observer` returns a dictionary mapping the function (or more specifically a string representation of the function) to the results of the function at each iteration it was called:
```julia
julia> results(obs)
Dict{String, Vector} with 2 entries:
julia> results(obs)
Dict{String, Vector} with 2 entries:
  "iteration"  => [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
  "err_from_π" => [0.00031831, 0.000159155, 0.000106103, 7.95775e-5, 6.3662e-5, 5.30516e-5…
```

Results can then be obtained from keys of the dictionary, either by passing the function itself:
```julia
julia> results(obs)[err_from_π]
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5
```
or the string representation of the function:
```julia
julia> results(obs)["err_from_π"]
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5
```

Additionally, the following is a shorthand for obtaining the
results of a particular function:
```julia
julia> results(obs, err_from_π)
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5
```
or with the string representation:
```julia
julia> results(obs, "err_from_π")
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5
```

## Custom function names

Alternatively, you can pass string names with the functions:
```julia
obs = Observer("Error" => err_from_π, "Iteration" => iteration)
```
in which case the results can be accessed from the given string names:
```julia
julia> results(obs, "Error")
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5

julia> results(obs, "Iteration")
10-element Vector{Int64}:
  1000
  2000
  3000
  4000
  5000
  6000
  7000
  8000
  9000
 10000
```

This is particularly useful if you pass anonymous function into the `Observer`.
For example:
```julia
julia> obs = Observer((; π_approx) -> abs(π - π_approx) / π, (; iteration) -> iteration);

julia> π_approx = my_iterative_function(niter; observer! = obs, observe_step = 1000)
3.1414926535900345

julia> results(obs)
Dict{String, Vector} with 2 entries:
  "#13" => [0.00031831, 0.000159155, 0.000106103, 7.95775e-5, 6.3662e-5, 5.30516e-5, 4.54728e-5, 3.97887e-5, 3.53678e-5, 3.1831e-…
  "#15" => [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
```
You can see that the names of the functions are automatically generated by Julia, since they are
[anonymous functions](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions).

This will make the results harder to access, since you would need to use the randomly
generated function name:
```julia
julia> results(obs, "#13")
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5

julia> results(obs, "#15")
10-element Vector{Int64}:
  1000
  2000
  3000
  4000
  5000
  6000
  7000
  8000
  9000
 10000
```

There are two alternatives. One is to save the anonymous functions in
variables and then pass them:
```julia
julia> err = (; π_approx) -> abs(π - π_approx) / π
#13 (generic function with 1 method)

julia> iter = (; iteration) -> iteration
#15 (generic function with 1 method)

julia> obs = Observer(err, iter);

julia> π_approx = my_iterative_function(niter; observer! = obs, observe_step = 1000)
3.1414926535900345

julia> results(obs)
Dict{String, Vector} with 2 entries:
  "#13" => [0.00031831, 0.000159155, 0.000106103, 7.95775e-5, 6.3662e-5, 5.30516e-5, 4.54728e-5, 3.97887e-5, 3.53678e-5, 3.1831e-…
  "#15" => [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
```
Then, you can use the variables that the functions were stored in to obtain the results:
```julia
julia> results(obs, err)
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5

julia> results(obs, iter)
10-element Vector{Int64}:
  1000
  2000
  3000
  4000
  5000
  6000
  7000
  8000
  9000
 10000
```

Alternatively, if you define the `Observer` with function names to begin with,
then you can get the results using the function names:
```julia
julia> obs = Observer("Error" => (; π_approx) -> abs(π - π_approx) / π, "Iteration" => (; iteration) -> iteration);

julia> π_approx = my_iterative_function(niter; observer! = obs, observe_step = 1000)
3.1414926535900345

julia> results(obs, "Error")
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5

julia> results(obs, "Iteration")
10-element Vector{Int64}:
  1000
  2000
  3000
  4000
  5000
  6000
  7000
  8000
  9000
 10000
```

## Reading and Writing to Disk

You can save and load Observers with packages like JLD2 (here we use the FileIO interface for JLD2):
```julia
# save the results dictionary as a JLD
using FileIO
save("results.jld2", obs)
obs_loaded = Observer(load("results.jld2"))
@show obs_loaded == obs
@show results(obs_loaded, "Error") == results(obs, "Error")
```

## Analyzing Results with DataFrames

In addition, you can convert the results of an Observer into a DataFrame and analyze and manipulate the results that way:
```julia
julia> using DataFrames

julia> df = DataFrame(results(obs))
10×2 DataFrame
 Row │ Error        Iteration 
     │ Float64      Int64     
─────┼────────────────────────
   1 │ 0.00031831        1000
   2 │ 0.000159155       2000
   3 │ 0.000106103       3000
   4 │ 7.95775e-5        4000
   5 │ 6.3662e-5         5000
   6 │ 5.30516e-5        6000
   7 │ 4.54728e-5        7000
   8 │ 3.97887e-5        8000
   9 │ 3.53678e-5        9000
  10 │ 3.1831e-5        10000

julia> df.Error
10-element Vector{Float64}:
 0.0003183098066059948
 0.0001591549331452938
 0.00010610329244741256
 7.957747030096378e-5
 6.366197660078155e-5
 5.305164733068067e-5
 4.54728406537879e-5
 3.978873562176942e-5
 3.536776502730045e-5
 3.18309885415475e-5

julia> df[4:6, :]
3×2 DataFrame
 Row │ Error       Iteration 
     │ Float64     Int64     
─────┼───────────────────────
   1 │ 7.95775e-5       4000
   2 │ 6.3662e-5        5000
   3 │ 5.30516e-5       6000
```
