--PIZZAS DE TAMANHO GRANDE OU FAMÍLIA QUE FORAM PEDIDAS PELA COMANDA 100

select count(*) as qtd
from pizza p
where p.comanda = 100
and p.tamanho in ('G', 'F');

--QUANTIDADE DE COMANDA NÃO PAGAS NOS ÚLTIMOS 365 DIAS

select count(*) as qtd
from comanda c
where c.pago is false
and data >= current_date - 365;

--QUANTIDADE MÉDIA DE INGREDIENTES POR SABOR

with qtd as (
    select s.codigo, s.nome, s.tipo, count(i.codigo) as soma
    from sabor s
    	join saboringrediente si on s.codigo = si.sabor
    	join ingrediente i on si.ingrediente = i.codigo
    group by s.codigo, s.nome, s.tipo
),
media as (
    select avg(soma) as media from qtd
)
select nome, soma, (select media from media) as media
from qtd;

--SABORES DOCES QUE POSSUEM MAIS DE 8 INGREDIENTES

select nome from (
    select s.codigo, s.nome, s.tipo, count(i.codigo) as soma
    from sabor s
    	join saboringrediente si on s.codigo = si.sabor
    	join ingrediente i on si.ingrediente = i.codigo
    where s.tipo = '3'
    group by s.codigo, s.nome, s.tipo
) as tmp
where soma > 8;

--DIAS QUE TIVERAM MAIS DE 10 COMANDAS NOS ÚLTIMOS 365 DIAS

select data from (
    select c.data, count(c.numero) as soma
    from comanda c
    where data >= now() - interval '365 day'
    group by data
) as tmp
where soma > 10;

--DIAS DA SEMANA QUE TIVERAM MENOS DE 20 COMANDAS NO ANO PASSADO

select to_char(data, 'day') as dias, count(*) as qtd
from comanda c
where c.data between date_trunc('year', now() - interval '1 year') 
             and date_trunc('year', now()) + interval '1 year' - interval '1 day'
group by 1
having count(*) < 20
order by 2 asc;

--RANKING DE SABORES MAIS PEDIDOS NOS ÚLTIMOS 365 DIAS

select nome, qtd from (
    select s.codigo, s.nome, count(ps.sabor) as qtd
    from sabor s
    	join pizzasabor ps on s.codigo = ps.sabor
    	join pizza p on ps.pizza = p.codigo
    	join comanda c on p.comanda = c.numero
    where c.data >= now() - interval '365 days'
    group by s.codigo, s.nome
) as tmp
order by qtd desc;

--VALOR DA COMANDA 45

select sum(tmp.preco) * 1.1 as preco
	from (select p.codigo, max(ppt.preco +
		  		case when b.preco is null
				then 0
				else b.preco end) as preco
		  from pizza p
				join pizzasabor ps on ps.pizza = p.codigo
				join sabor s on ps.sabor = s.codigo
				join precoportamanho ppt on ppt.tipo = s.tipo and ppt.tamanho = p.tamanho
				left join borda b on p.borda = b.codigo
		  where p.comanda = 45
		  group by p.codigo) as tmp;

--SABORES QUE CONTÉM O INGREDIENTE BACON

select s.nome
from sabor s
	join saboringrediente si on s.codigo = si.sabor
	join ingrediente i on i.codigo = si.ingrediente
where i.nome = 'BACON'
order by s.codigo desc;

--SABORES SALGADOS QUE POSSUEM MAIS DE 8 INGREDIENTES

select nome from (
    select s.codigo, s.nome, s.tipo, count(i.codigo) as soma
    from sabor s
    	join saboringrediente si on s.codigo = si.sabor
    	join ingrediente i on si.ingrediente = i.codigo
    where s.tipo in ('1', '2')
    group by s.codigo, s.nome, s.tipo
) as tmp
where soma > 8;

--SABORES SALGADOS PEDIDOS MAIS DE 20 VEZES ANO PASSADO

select nome, qtd from (
    select s.codigo, s.nome, s.tipo, count(ps.sabor) as qtd
    from sabor s
    	join pizzasabor ps on s.codigo = ps.sabor
    	join pizza p on ps.pizza = p.codigo
    	join comanda c on p.comanda = c.numero
    where c.data >= date_trunc('year', now()) - interval '1 year'
    group by s.codigo, s.nome, s.tipo
) as tmp
where qtd > 20 and tipo in ('1', '2')
order by qtd desc;

--INGREDIENTES MAIS PEDIDOS NOS ÚLTIMOS 12 MESES

select nome, qtd from (
    select i.codigo, i.nome, count(si.ingrediente) as qtd
    from ingrediente i
    	join saboringrediente si on i.codigo = si.ingrediente
    	join sabor s on si.sabor = s.codigo
    	join pizzasabor ps on s.codigo = ps.sabor
    	join pizza p on ps.pizza = p.codigo
    	join comanda c on p.comanda = c.numero
    where c.data >= now() - interval '12 month'
    group by i.codigo, i.nome
) as tmp
order by qtd desc;

--RANKING DOS SABORES DOCES MAIS PEDIDOS NOS ÚLTIMOS 12 MESES POR MÊS

select nome, mes, qtd from (
    select s.codigo, s.nome, extract(month from c.data) as mes, count(ps.sabor) as qtd
    from sabor s
    	join pizzasabor ps on s.codigo = ps.sabor
    	join pizza p on ps.pizza = p.codigo
    	join comanda c on p.comanda = c.numero
    where c.data >= now() - interval '12 months'
    group by s.codigo, s.nome, mes
) as tmp
order by mes desc, qtd desc;

--QUANTIDADE DE PIZZAS PEDIDOS POR TIPO POR TAMANHO NOS ÚLTIMOS 6 MESES

with pedidos as (
   select ps.sabor, p.tamanho, c.data
   from pizza p
   		join pizzasabor ps on p.codigo = ps.pizza
   		join comanda c on p.comanda = c.numero   	
   where c.data >= now() - interval '12 months'
)
select t.nome, tm.nome, count(ps.sabor) as qtd
from pedidos ps
	join tamanho tm on ps.tamanho = tm.codigo
	join precoportamanho pt on tm.codigo = pt.tamanho
	join tipo t on pt.tipo = t.codigo
	join sabor s on t.codigo = s.tipo
group by t.nome, tm.nome
order by 1 desc;

--RANKING DE INGREDIENTES MAIS PEDIDOS ACOMPANHANDO CADA BORDA NOS ÚLTIMOS 12 MESES

select i.nome, count(*) as qtd
from pizza p
	join pizzasabor ps on p.codigo = ps.pizza
	join sabor s on ps.sabor = s.codigo
	join saboringrediente si on s.codigo = si.sabor
	join ingrediente i on si.ingrediente = i.codigo
	join comanda c on p.comanda = c.numero
where c.data >= (now() - interval '12 months') and p.borda is not null
group by i.nome
order by qtd desc;

--MESA MENOS UTILIZADA NOS ÚLTIMOS 365 DIAS

select m.nome, count(c.mesa) as qtd
from comanda c
	join mesa m on c.mesa = m.codigo
where c.data >= now() - interval '365 day'
group by m.nome
order by qtd asc
limit 1;

--SABOR MAIS PEDIDO POR TIPO NO ANO PASSADO

select s.nome as sabor, t.nome as tipo
from comanda c
	join pizza p on p.comanda = c.numero
	join pizzasabor ps on ps.pizza = p.codigo
	join sabor s on ps.sabor = s.codigo
	join tipo t on s.tipo = t.codigo
where extract(year from c.data) = extract(year from now())-1
group by 1, 2
having (t.nome, count(1)) in
	(select tmp.tipo, max(tmp.qtd)
	from
		(select s.nome as sabor, t.nome as tipo, count(1) as qtd
		from comanda c
			join pizza p on p.comanda = c.numero
			join pizzasabor ps on ps.pizza = p.codigo
			join sabor s on ps.sabor = s.codigo
			join tipo t on s.tipo = t.codigo
		where extract(year from c.data) = extract(year from now())-1
		group by 1, 2) as tmp
	group by tmp.tipo);

--FORNECEDOR DA MARCA DE BEBIDA 12

select m.nome as nome_marca, f.nome as nomefornecedor
from marca m
    join fornecedor f on m.fornecedor = f.codigo
where m.codigo = 12;

--TODOS OS FORNECEDORES

select distinct f.nome as nomefornecedor
from fornecedor f
	join ingrediente i on f.codigo = i.fornecedor
	join marca m on i.fornecedor = m.fornecedor;

--TODOS OS INGREDIENTES E SEUS FORNECEDORES

select i.codigo as codigo, i.nome as ingrediente, f.nome as fornecedor
from ingrediente as i
	join fornecedor as f on i.fornecedor = f.codigo;
