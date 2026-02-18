# Instagram Graph Analysis -- Neo4j Project

## 📌 Overview

Este projeto implementa um modelo de grafo inspirado na estrutura do
Instagram utilizando Neo4j e Cypher. O objetivo é demonstrar modelagem
de grafos sociais, análise de centralidade, caminhos mínimos,
engajamento e recomendações.

O projeto está organizado em quatro arquivos principais para melhor
modularização e execução controlada.

------------------------------------------------------------------------

# 📂 Estrutura Final do Projeto

## 01_schema.cypher

Responsável por:

-   Criação de constraints
-   Definição de unicidade (User.id)
-   Preparação da base estrutural do grafo

Este arquivo deve ser executado primeiro.

------------------------------------------------------------------------

## 02_import.cypher

Responsável por:

-   Criação de usuários principais
-   Criação de posts
-   Criação de relações:
    -   FOLLOWS
    -   POSTED
    -   LIKES
    -   COMMENTS
-   Inserção de dados iniciais para análise

Este arquivo popula o grafo.

------------------------------------------------------------------------

## 03_analysis.cypher

Responsável por:

-   Degree Centrality (in-degree / out-degree)
-   Shortest Path
-   Recomendações baseadas em amigos de amigos
-   Cálculo de engajamento
-   Consultas analíticas gerais

Contém as principais análises do projeto.

------------------------------------------------------------------------

## 04_test_structure.cypher

Responsável por:

-   Criação de 7 usuários artificiais (IDs 2000--2006)
-   Criação de estrutura linear FOLLOWS: 2000 → 2001 → 2002 → 2003 →
    2004 → 2005 → 2006
-   Verificação estrutural da rede

Utilizado para testar algoritmos de caminho e centralidade de forma
controlada.

------------------------------------------------------------------------

# 🧠 Conceitos Aplicados

-   Modelagem de Grafos Sociais
-   Relacionamentos direcionais
-   Degree Centrality
-   Shortest Path
-   Análise de Engajamento
-   Recomendação baseada em vizinhança

------------------------------------------------------------------------

# ⚙️ Ordem de Execução Recomendada

1.  01_schema.cypher
2.  02_import.cypher
3.  04_test_structure.cypher (opcional para testes)
4.  03_analysis.cypher

------------------------------------------------------------------------

# 🔒 Boas Práticas Aplicadas

-   Uso de MERGE para evitar duplicações
-   Uso de OPTIONAL MATCH para evitar falhas
-   Organização em blocos numerados
-   Estrutura idempotente
-   Compatível com Neo4j 4.x e 5.x

------------------------------------------------------------------------

# 🎯 Status Final

✔ Estrutura modularizada\
✔ Código revisado e corrigido\
✔ Sem duplicações críticas\
✔ Academic-ready\
✔ Portfolio-ready

------------------------------------------------------------------------

# 👤 Autor

John Peter Oyardo Omanrique

------------------------------------------------------------------------

Projeto final consolidado e validado.
