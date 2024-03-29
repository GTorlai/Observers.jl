# Convenient constructors of DataFrames with functions as column metadata,
# called an "observer".

observer() = DataFrame()

# In general, fall back to `DataFrame` constructors.
observer(args...; kwargs...) = DataFrame(args...; kwargs...)

# Treat function column data as column metadata.
# Default to empty columns with element type `Union{}`
# so they get automatically promoted to the first type that gets pushed
# into them.
function observer(
  name_function_pairs::Vector{<:Pair{T,<:Function}}; kwargs...
) where {T<:Union{Symbol,String}}
  df = DataFrame(
    [first(name_function) => Union{}[] for name_function in name_function_pairs]; kwargs...
  )
  name_function_dict = Dict(name_function_pairs)
  for name in keys(name_function_dict)
    set_function!(df, name, name_function_dict[name])
  end
  return df
end

function observer(
  key_function_pairs::Pair{T,<:Function}...; kwargs...
) where {T<:Union{Symbol,String}}
  return observer(Pair{T,Function}[key_function_pairs...]; kwargs...)
end

function observer(functions::Vector{<:Function}; kwargs...)
  return observer(
    Pair{String,Function}[string(func) => func for func in functions]; kwargs...
  )
end

function observer(functions::Function...; kwargs...)
  return observer(
    Pair{String,Function}[string(func) => func for func in functions]; kwargs...
  )
end
