CREATE TABLE tamanho (
	codigo char(1) not null,
	nome varchar(100) not null,
	qtdesabores integer not null check (qtdesabores > 0),
	primary key (codigo)
);

CREATE TABLE tipo (
	codigo integer not null,
	nome varchar(100) not null,
	primary key (codigo)
);

CREATE TABLE fornecedor (
	codigo integer not null,
	nome varchar(100) not null,
	contato varchar(100) not null,
	endereco jsonb,
	primary key (codigo)
);

CREATE TABLE ingrediente (
	codigo integer not null,
	nome varchar(100) not null,
	fornecedor integer not null,
	foreign key (fornecedor) references fornecedor(codigo),
	primary key (codigo)
);

CREATE TABLE sabor (
	codigo integer not null,
	nome varchar(100) not null,
	tipo integer not null,
	foreign key (tipo) references tipo(codigo),
	primary key (codigo)
);

CREATE TABLE marca (
    codigo integer not null,
	nome varchar(100) not null,
	fornecedor integer not null,
	preco real not null check (preco > 0),
	foreign key (fornecedor) references fornecedor(codigo),
	primary key (codigo)
);

CREATE TABLE borda (
	codigo integer not null,
	nome varchar(100) not null,
	preco real not null check (preco > 0),
	primary key (codigo)
);

CREATE TABLE mesa (
	codigo integer not null,
	nome varchar(100) not null,
	primary key (codigo)
);

CREATE TABLE saboringrediente (
	sabor integer not null,
	ingrediente integer not null,
	foreign key (sabor) references sabor(codigo),
	foreign key (ingrediente) references ingrediente(codigo),
	primary key (sabor, ingrediente)
);

CREATE TABLE precoportamanho (
	tipo integer not null,
	tamanho char(1) not null,
	preco real not null check (preco > 0),
	foreign key (tipo) references tipo(codigo),
	foreign key (tamanho) references tamanho(codigo),
	primary key (tipo, tamanho)
);

CREATE TABLE comanda (
	numero integer not null,
	data date not null default current_date,
	mesa integer not null,
	pago boolean not null default false,
	foreign key (mesa) references mesa(codigo),
	primary key (numero)
);

CREATE TABLE pizza (
	codigo integer not null,
	comanda integer not null,
	tamanho char(1) not null,
	borda integer,
	foreign key (comanda) references comanda(numero),
	foreign key (tamanho) references tamanho(codigo),
	foreign key (borda) references borda(codigo),
	primary key (codigo)
);

CREATE TABLE bebida (
	codigo integer not null,
	comanda integer not null,
	foreign key (comanda) references comanda(numero),
	primary key (codigo)
);

CREATE TABLE pizzasabor (
	pizza integer not null,
	sabor integer not null,
	foreign key (pizza) references pizza(codigo),
	foreign key (sabor) references sabor(codigo),
	primary key (pizza, sabor)
);

CREATE TABLE bebidamarca (
	bebida integer not null,
	marca integer not null,
	foreign key (bebida) references bebida(codigo),
	foreign key (marca) references marca(codigo),
	primary key (bebida, marca)
);
