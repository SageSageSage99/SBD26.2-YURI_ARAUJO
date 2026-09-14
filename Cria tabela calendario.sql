create table TB_CALENDARIO
(
    dt_ref date not null,
    ano number(4) not null,
    mes number(2) not null,
    dia number(2) not null,
    trimestre number(1) not null,
    nome_mes varchar2(15) not null,
    dia_semana number(1) not null,
    nome_dia_semana varchar2(15) not null,

    -- constraints
        -- pk
        constraint pk_tb_calendario primary key(dt_ref)
);