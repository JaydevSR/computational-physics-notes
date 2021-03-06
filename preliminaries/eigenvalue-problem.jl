### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ db092860-fb82-44f9-9543-7fcd08b3d39c
begin
	using PlutoUI
	PlutoUI.TableOfContents()
end

# ╔═╡ 60dfd5d2-f809-11eb-3e94-af4a3099da9c
md"# Preliminaries: The Eigenvalue Problem"

# ╔═╡ a4327b5f-399b-4e81-bc22-72038757c275
md"""
## Power Iteration Method

- This is the simplest method used for numerical solution of the eigenvalue problem.

- Given a matrix $A\in\mathbb{C}^{N\times N}$, subject to some constraints:
  1. A is diagonalizable. For example, a Hermitian matrix.
  2. The eigenvalues can be ordered as $|\lambda_1| > |\lambda_2| \ge \dots \ge |\lambda_N|$. Here, $\lambda_1$ is called _the dominant eigenvalue_ and the corresponding eigenvector is called the _dominant eigenvector_.

- This method can only be used to calculate the dominant eigenvalue and eigenvector.

!!! tip "Power Iteration Method"
	As the matrix $A$ is diagonalizable, the eigenvectors $\mathbf{v}_1, \dots, \mathbf{v}_N$ are linearly independent and span $\mathbb{R}^N$. So, for some $\mathbf{x}_0 \in \mathbb{R}^N$ we have:

	$\mathbf{x}_0 = \sum_{i=1}^{N} c_i \mathbf{v}_i$
	$\implies \mathbf{x}_n = A^n\mathbf{x}_0 = \sum_{i=1}^{N} c_i A^n \mathbf{v}_i = \sum_{i=1}^{N} c_i \lambda_i^n \mathbf{v}_i$
	$\implies \mathbf{x}_n = c_1 \lambda_1^n \mathbf{v}_1 + \lambda_1^n\sum_{i=2}^{N} c_i \frac{\lambda_i^n}{\lambda_1^n} \mathbf{v}_i$
	Now, as $n \rightarrow \infty$, we get that $\mathbf{x}_n \rightarrow c_1 \lambda_1^n \mathbf{v}_1$ as the dominant eigenvalue is strictly greater than all other eigenvalues. Thus we can get the dominant eigenvector by repetative multiplication of a vector $\mathbf{x}_0$ by matrix $A$ and then normalizing the result.

	We can also find the dominant eigenvalue by using the [Rayleigh quotient](https://en.wikipedia.org/wiki/Rayleigh_quotient) as:
	
	$\lim_{n\to\infty} \frac{\mathbf{x}_n^† A \mathbf{x}_n}{\mathbf{x}_n^*\cdot\mathbf{x}_n} = \lambda_1$

- We can't use this method if $c_1=0$ i.e. $\mathbf{x}_0$ and $\mathbf{v}_1$ are ortogonal. But as we can't know the dominant eigenvector beforehand we can make a guess and hope for the best.

- Also, if $|\lambda_1| > 1$ then with each iteration the components of the iterated vector will grow and may reach out of bounds of the precision of floating point numbers for large $n$. To prevent this we can normalize the vector again at each iteration resulting in the _normalized power iteration method_.

- This algorithm has **linear convergence** for any general matrix, whereas **quadratic convergence** for Hermitian or real-symmetric matrices. The closer $\mathbf{x}_0$ is to $\mathbf{v}_1$, the better the convergence will be.

"""

# ╔═╡ 2e38803f-a24b-4b73-b947-1a4dbe11a60c
md"""
!!! info "Code"
	
	To check the convergence we check for the difference between consecutive rayleigh coefficients to be small within some limit. If we only need the to calculate the eigenvector then we can save time by not using rayleigh coefficients and only checking for the norm of difference between the vectors in two consecutive iterations to be within some small limit.

	```julia
	using LinearAlgebra

	rayleigh_quotient(A::Matrix, x::Vector) = dot(x, A, x) / dot(x, x)

	#= 
	Example Matrix
	Dominant Eigenvalue: 8.45188
	Dominant Eigenvector: [0.3398 − 0.2345i, 0.4913 + 0.5107i, 0.5011 − 0.2762i]
	=#
	A = [ 4+0im  0-1im  2+0im;
		  0+1im  2+0im  2+7im;
		  2+0im  2-7im -2+0im]

	# Starting Vector
	x = normalize([1+0im;
				   1+0im; 
				   1+0im])

	RQold = 0
	RQnew = rayleigh_quotient(A, x)

	# Power Iteration
	while (abs(RQnew - RQold) > 1e-6)
		RQold = RQnew
		x = normalize(A * x)
		RQnew = rayleigh_quotient(A, x)
	end

	println("The dominant eigenvalue is: $(RQnew)")
	println("The dominant eigenvector is: $(x)")
	```
	$\quad$
"""

# ╔═╡ 59cf1c89-3292-40d6-ace2-6b0d15d671a0
html"<br>"

# ╔═╡ dcd3b0e7-e72c-4e1e-8903-b760d97126af
md"""
### Inverse Power Iteration method

- We can also calculate the _**smallest eigenvalue**_ and the corresponding eigenvector of a matrix $A \in \mathbb{C}^{N\times N}$ with the same requirements as in the power iteration method using a trick.

- We use the fact that the eigenvalues of the inverse matrix $A^{-1}$ are the inverse of eigenvalues of $A$ with the same eigenvectors. So, if a smallest eigenvalue exists for $A$ then we can use power iteration on $A^{-1}$.

- Usually for big matrices finding the inverse is a challenging task so we can restate the problem in another way to make it easier to solve as:

$\text{Power iteration step:}\quad x_{n+1} = A^{-1}x_n$
$\text{Other way:}\quad Ax_{n+1} = x_n$

- The other way to find the power iteration above is simply in the form of system of linear equation which can be solved more easily with known algorithms for big matrices and saves us from calculating the inverse matrix.

"""

# ╔═╡ 07bf571a-c7ea-4bab-b73f-e1306a94c000
html"<br>"

# ╔═╡ fb34b547-94af-4cfb-aafc-5fb78792fd42
md"
### Rayleigh Quotient iteration

- This is another variation of power iteration method that can _possibly_ calculate _**any eigenvalue and eigenvector**_ of the given matrix.

- This method utilizes the fact that the eigenvalues of the matrix $A - \mu I$ are given by $\lambda_1 - \mu, \lambda_2 - \mu, \dots, \lambda_N - \mu$. If we manage to find an initial guess for $\mu$ that is sufficiently close to some eigenvalue $\lambda_i$ such that the ordereing of eigenvalues of matrix $A - \mu I$ is given by,

$|\lambda_1 - \mu| > |\lambda_2 - \mu| \ge \dots > |\lambda_i - \mu|$

- Then, we can find the eigenvalue $\lambda_i$ by using the _inverse power iteration method_ on the matirix $A - \mu I$. We can update the value of $\mu$ on each iteration to be Rayleigh coefficient of the iteration eigenvector with matrix $A$. Due to this the final value of $\mu$ will be equal to $\lambda_i$. This also leads to better convergence.

- There is a caveat here though that to find the complete eigensystem we may need to make multiple guesses for $\mu$ in order to cover the complete spectrum of eigenvalues to find them all. So, this method should only be used if we know that a particular eigenvalue is in some fixed range.
"

# ╔═╡ 1b93b221-d6c2-44f1-b909-d28d086f1226
html"<br>"

# ╔═╡ 37fb70ca-1f90-4ba8-ab81-b1f60c971357
md"""
### Method of deflation

- This method can be used to find _**all the eigenvalues and eigenvectors**_ of a **Hermitian** matrix in order by subsequent orthonormalization.

- Once we have found the dominant eigenvalue and eigenvector. Then we can now use the following method to find the next eigenvalue and the corresponding eigenvector in order:

!!! tip "Method of Deflation"
	Consider the matrix $A' = A - \lambda_1 \mathbf{v}_1 \mathbf{v}_1 ^\dagger$. Then if the eigenvectors are normalized we have:

	$A'\mathbf{v}_1 = A\mathbf{v}_1 - \lambda_1 \mathbf{v}_1 = 0$

	But for any other eigenvector, $\mathbf{v}_i$ where $i\ne 1$, we have:

	$A'\mathbf{v}_i = A\mathbf{v}_i - 0 = \lambda_i \mathbf{v}_i$

	As the eigenvectors of a Hermitian matrix are orthonormal. So, the eigenvalue spectrum of of the new matrix $A'$ is the same as $A$ but with $\mathbf{v}_1$ projected out of the space. So, we can now apply the power iteration method to find the next eigenvalue as for the new subspace:
	
	$\mathbf{x}_n = c_2 \lambda_2^n \mathbf{v}_2 + \lambda_2^n\sum_{i=3}^{N} c_i \frac{\lambda_i^n}{\lambda_2^n} \mathbf{v}_i$

- **Note**: The error that is present in calculating one eigenvalue is propogated to the calculation of the next eigenvalue. So, the errors tend to accumulate towards the final eigenvalue in the order.
"""

# ╔═╡ 766e180a-004b-4fa4-a55e-a2ca892645f8
html"<br><br>"

# ╔═╡ cbc0d76d-f9a6-4159-b86a-8395f35df19b
md"## Krylov Subspace Techniques"

# ╔═╡ 2d4c88f6-9344-4a0f-ba9f-0fdae61112e2
md"""
- For a matrix, $A\in \mathbb{C}^{N\times N}$, and an arbitrary vector $\mathbf{x}\in\mathbb{C}^N$, the _Krylov Subspace_ of $r^{th}$ order is given by:

$\mathcal{K}_r(A, \mathbf{x}) = span(\{\mathbf{x}, A\mathbf{x}, A^2\mathbf{x}, \dots, A^{r-1}\mathbf{x}\})$

- Any vector $\mathbf{u}\in\mathcal{K}_r$ can be written as $\sum_{i=1}^{r} c_i A^{i-1} \mathbf{x}$. This not the most suitable basis representation as it is not orthonormal. So, we orthonormalize this basis to find a new basis:

$\mathcal{Q}_r = \{\mathbf{q}_1, \mathbf{q}_2, \dots, \mathbf{q}_r\}$

- If the matrix $A$ is Hermitian then the above basis is called _**Lanczos basis**_. Otherwise it's called _Arnoldi basis_.

- One of the important properties of Krylov subspaces is the following which can easily be verified using some vector space properties:

$\mathcal{K}_{r+1}(A, \mathbf{x}) = span(\mathcal{Q}_r \cup\{A\mathbf{q_r}\})$
$\text{where,}\quad\mathcal{Q}_r=\{\mathbf{q}_1, \mathbf{q}_2, \dots, \mathbf{q}_r\}$

- Due to the above property, it is very easy to expand the Krylov subspace to higher orders because in instead of orthonormalizing the whole Krylov basis for $\mathcal{K}_{r+1}$, we only need to orthonormalize one vector $A\mathbf{q}_r$ _w.r.t._ the orthonormal basis of $\mathcal{K}_{r}$

"""

# ╔═╡ a6c20c0c-1695-4610-8888-80347494b3f1
md"""
### Lanczos Tridiagonalization

- _Lanczos iteration method_ is an iterative method for finding the Lanczos basis of the Krylov subspace corresponding to a Hermitian matrix.
- Why though? Well, we can use the Lanczos basis to tridiagonalize the matrix which makes it easier to find eigenvalues using other methods as the matrix becomes almost a diagonal matrix.
- For this we make use of the following theorems:

!!! warning "Theorem"
	For every hermitian matrix $A\in \mathbb{C}^{N\times N}$, $\exists$ a unitary matrix $Q \in \mathbb{C}^{N\times N},\ Q^\dagger Q = I$ such that:

	$Q^\dagger A Q = T$

	Where $T$ is a _symmetric tridiagonal matrix_.

!!! warning "Theorem"
	The unitary matrix given by $Q_N = [\mathbf{q}_1, \dots, \mathbf{q}_N]$ whose columns are the Lanczos basis vectors, tridiagonalizes the corresponding Hermitian matrix $A \in \mathbb{C}^{N\times N}$.
"""

# ╔═╡ b799e8f3-7172-4bd1-ab61-183741a49a6c
md"""
!!! danger "Read Slowly!"

- Now we write the tridiagonal matrix as:
$T = \begin{bmatrix}a_1 & b1 & \ & \ \\ b1 & a2 & \ddots & \ \\ \ & \ddots & \ddots & b_{N-1} \\ \ & \ & b_{N-1} & a_{N}\end{bmatrix}$

- Then if we write the tridiagonalization equation as $AQ_N = Q_NT$ then we get:
$(Aq_1 , Aq_2 , . . . , Aq_N )
= (a_1 q_1 + b_1 q_2 , b_1 q_1 + a_2 q_2 + b_2 q_3 , . . . , b_{N−1} q_{N−1} + a_N q_N )$

- Here $q_i$ are column vectors of $Q_N$. From the above equation we get a system of equation to directly solve for Lanczos vectors:

$\begin{align*}
b_1\mathbf{q}_2 &= (A-a_1)\mathbf{q}_1\\	
b_{i-1}\mathbf{q}_i &= (A-a_{i-1})\mathbf{q}_i-1 - b_{i-2}\mathbf{q}_{i-2},\quad 2 < i < N-1 \\
0 &= (A - a_N)\mathbf{q}_{N} - b_{N-1}\mathbf{q}_{N-1}
\end{align*}$

- Now for finding the Lanczos vectors and the elements of tridiagonal matrix we simplify this system a bit:
  1. As, $\mathbf{q}_1$ can be any normalized vector, so we choose a random vector $\mathbf{x_0}$ and take $b_0 \mathbf{q_1} = \mathbf{x}_0$. Where $b_0 = |\mathbf{x}_0|$ to keep $\mathbf{q_1}$ normalized.
  2. Also we have $a_i = \mathbf{q}_i^\dagger A \mathbf{q}_i$ from the matrix multiplication. And now we define $\mathbf{x}_i = (A-a_{i-1})\mathbf{q}_i-1 - b_{i-2}\mathbf{q}_{i-2}$ for $1 \le i \le N$ so that our system of equations becomes:

  $\text{For } 1 \le i < N:\ b_{i-1}\mathbf{q}_i = \mathbf{x}_{i-1},\ \text{and }\mathbf{x}_N = 0$
  3. For $\mathbf{q}_i$ to be normalized we have $b_{i} = |\mathbf{x}_{i}| > 0$. But as $b_0 \ne 0$ so we define $\mathbf{q}_0=0$ such that we get the proper equation for $\mathbf{q}_2$.

- **Note**: The method of Lanczos iteration is very much sensitive to round off errors and hence is also prone to instability. On way to reduce such instabilities is to explicitly renormalize the complete set $\{\mathbf{q}_1, \dots, \mathbf{q}_i\}$ on $i^{th}$ iteration at the cost of computational time.
"""

# ╔═╡ 853d533b-a47a-4155-8a59-d741f6a0e936
md"""
!!! info "Code for Lanczos Iteration"
	$\quad$
	```julia
	using Random, LinearAlgebra

	# Example Matrix
	A = [ 2.00+0.0im -1.00+1.0im  0.00-0.5im  4.25+0.0im;
		 -1.00-1.0im  4.00+0.0im  1.00+0.0im  7.00+0.0im;
		  0.00+0.5im  1.00+0.0im  2.00+0.0im -1.00+2.0im;
		  4.25+0.0im  7.00+0.0im -1.00-2.0im  1.40+0.0im]

	N = size(A)[1]

	# Initialization
	x = rand(Float64, N)          # random starting vector x0
	a = [zero(Complex{Float64})]  # a0, ..., aN
	b = [Complex(norm(x))]	      # b0, ..., bN
	qii = zeros(N)                # q_{i-1} initialized to q₀=0

	# Lanczos iteration
	for n=1:N
		i=n+1                     # For 1 based indexing
		qi = x / b[i-1]
		push!(a, dot(qi, A, qi))
		x = A*qi - a[i]*qi - b[i-1]*qii
		push!(b, norm(x))
		qii = qi
	end

	# Remove very small imaginary parts
	if_close_then_real(z) = isapprox(imag(z), 0, atol=1e10) ? real(z)+0.0im : z
	a = [if_close_then_real(x) for x ∈ a]
	b = [if_close_then_real(x) for x ∈ b]

	# Construct the tridiagonal matrix
	T = Matrix(Tridiagonal(b[2:end-1], a[2:end], b[2:end-1]))
	```
	$\quad$
"""	

# ╔═╡ 5a2fb1ae-22dd-4b4f-adc8-d1ff2763860f
html"<br><br>"

# ╔═╡ 4f459acb-97fa-48fd-b044-e14b63575c39
md"
## Packages

- **LinearAlgebra.jl**
- **scipy.linalg** module
"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "477bf42b4d1496b454c10cce46645bb5b8a0cf2c"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.2"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╟─60dfd5d2-f809-11eb-3e94-af4a3099da9c
# ╟─db092860-fb82-44f9-9543-7fcd08b3d39c
# ╟─a4327b5f-399b-4e81-bc22-72038757c275
# ╟─2e38803f-a24b-4b73-b947-1a4dbe11a60c
# ╟─59cf1c89-3292-40d6-ace2-6b0d15d671a0
# ╟─dcd3b0e7-e72c-4e1e-8903-b760d97126af
# ╟─07bf571a-c7ea-4bab-b73f-e1306a94c000
# ╟─fb34b547-94af-4cfb-aafc-5fb78792fd42
# ╟─1b93b221-d6c2-44f1-b909-d28d086f1226
# ╟─37fb70ca-1f90-4ba8-ab81-b1f60c971357
# ╟─766e180a-004b-4fa4-a55e-a2ca892645f8
# ╟─cbc0d76d-f9a6-4159-b86a-8395f35df19b
# ╟─2d4c88f6-9344-4a0f-ba9f-0fdae61112e2
# ╟─a6c20c0c-1695-4610-8888-80347494b3f1
# ╟─b799e8f3-7172-4bd1-ab61-183741a49a6c
# ╟─853d533b-a47a-4155-8a59-d741f6a0e936
# ╟─5a2fb1ae-22dd-4b4f-adc8-d1ff2763860f
# ╟─4f459acb-97fa-48fd-b044-e14b63575c39
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
