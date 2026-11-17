using JuMP
using HiGHS

# Puxa o arquivo .dat
data = open(ARGS[1],"r")

# Definicao do tamanho do problema
obj = parse(UInt8, readline(data)) # Definicao de max ou min
n = parse(UInt8, readline(data)) # Numero de variaveis
m = parse(UInt8, readline(data)) # Numero de restricoes

# Criacao dos vetores/matrizes
b = zeros(m)		
A = zeros(m, n)		# Ax <= ou >= b (restricoes do problema)
c = zeros(n)		# Funcao objetivo

#############################
# Leitura dos valores do .dat
#############################

# Leitura do vetor b
for i = 1 : m
 	b[i] = parse(Float64, readline(data))
end

# Leitura da matriz A
for i = 1 : m
	s = split(readline(data))
	for j = 1 : n
		A[i,j] = parse(Float64, s[j])
	end
end 

# Leitura do vetor c
for j = 1 : n
		c[j] = parse(Float64, readline(data))
end 

close(data) # Fecha o aquivo .dat

# Display para verificar os valores
display(b) 
display(A)
display(c)

#####################
# Execucao do Simplex 
#####################

# Criacao do modelo
LP = Model(HiGHS.Optimizer)
set_attribute(LP, "threads", 1)
set_attribute(LP, "simplex_strategy", 1)

# Definicao de variaveis
@variable(LP,  x[j=1:n] >= 0)

# Definicao da funcao objetivo
if obj == 0
	@objective(LP, Min, sum(c[j]*x[j] for j = 1:n))
else
	@objective(LP, Max, sum(c[j]*x[j] for j = 1:n))
end

# Restricoes
@constraint(LP, r1[i=1:m], sum(A[i,j]*x[j] for j = 1:n) <= b[i])

# Resolvendo 
optimize!(LP)

# Saidas
print("LP Resolvido! FO ótima LP: ")
println(objective_value(LP))
display(value.(x))
