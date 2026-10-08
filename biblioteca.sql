
CREATE TABLE leitores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL CHECK (LENGTH(cpf) = 11),
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE livros (
    id SERIAL PRIMARY KEY,
    categoria_id INT,
    titulo VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    taxa_diaria DECIMAL(10,2) NOT NULL CHECK (taxa_diaria > 0),
    disponivel BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE emprestimos (
    id SERIAL PRIMARY KEY,
    leitor_id INT,
    data_emprestimo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativo'
        CHECK (status IN ('Ativo', 'Devolvido', 'Atrasado')),
    FOREIGN KEY (leitor_id) REFERENCES leitores(id)
);

CREATE TABLE itens_emprestimo (
    id SERIAL PRIMARY KEY,
    emprestimo_id INT,
    livro_id INT,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    valor_diaria DECIMAL(10,2) NOT NULL CHECK (valor_diaria >= 0),
    FOREIGN KEY (emprestimo_id) REFERENCES emprestimos(id),
    FOREIGN KEY (livro_id) REFERENCES livros(id)
);


INSERT INTO categorias (nome) VALUES
('Ficção'),
('História'),
('Tecnologia');

INSERT INTO livros
    (categoria_id, titulo, isbn, taxa_diaria, disponivel) VALUES
(1, 'A Ilha dos Mistérios', '9780000000019', 2.50, FALSE),
(2, 'História do Brasil', '9780000000026', 3.00, TRUE),
(3, 'Introdução à Tecnologia', '9780000000033', 4.00, FALSE);

INSERT INTO leitores (nome, email, cpf, telefone) VALUES
('Ana Souza', 'ana@example.com', '11111111111', '48999990001'),
('Bruno Lima', 'bruno@example.com', '22222222222', '48999990002'),
('Carla Santos', 'carla@example.com', '33333333333', '48999990003');

INSERT INTO emprestimos (leitor_id, status) VALUES
(1, 'Ativo'),
(2, 'Devolvido'),
(3, 'Atrasado'),
(1, 'Devolvido');

INSERT INTO itens_emprestimo
    (emprestimo_id, livro_id, quantidade, valor_diaria) VALUES
(1, 1, 1, 2.50),
(2, 2, 1, 3.00),
(3, 3, 1, 4.00),
(4, 2, 2, 3.00); 
------------------------------------------------------------------------------------------
--Q1
	create VIEW vw_acervo_ordenado as
	select
		l.titulo,
		l.isbn,
		c.nome as categoria,
		l.taxa_diaria

	from livros l
	join categorias c on l.categoria_id = c.id

	order by l.taxa_diaria DESC

-- Q2
	CREATE VIEW vw_emprestimos_carlos as
	select 
		leitores.nome,
		e.id as id_emprestimo,
		e.data_emprestimo,
		l.titulo,
		ie.quantidade,
		e.status 
	from
		itens_emprestimo ie
	join emprestimos e on ie.emprestimo_id = e.id
	join livros l ON ie.livro_id = l.id
	join leitores on e.leitor_id = leitores.id
	WHERE leitores.nome = 'Carlos Silva'


-- Q3
	CREATE VIEW vw_total_emprestimos as
	select
		e.id as id_emprestimo,
		l.nome as leitor,
	    sum(ie.quantidade * livros.taxa_diaria) as valor_total
	from
		itens_emprestimo ie
	join emprestimos e on ie.emprestimo_id = e.id
	join livros on ie.livro_id = livros.id
	join leitores l on e.leitor_id = l.id
	group by id_emprestimo, l.nome

--Q4
	select
	livros.titulo as nome_livro
	from
		livros,
		categorias
	WHERE
		categorias.nome = 'Ficção' AND
		livros.taxa_diaria > 5 and
		livros.disponivel = TRUE

--Q5
	create VIEW vw_faturamento_por_categoria AS
	SELECT
		c.nome AS categoria,
		SUM(ie.quantidade * ie.valor_diaria) AS total_arrecadado
	FROM livros l
	JOIN categorias c ON l.categoria_id = c.id
	JOIN itens_emprestimo ie ON ie.livro_id = l.id
	JOIN emprestimos e ON ie.emprestimo_id = e.id
	WHERE e.status = 'Devolvido'
	GROUP BY c.nome