Diagrama DER
```mermaid
erDiagram
    usuarios ||--|| escolas : "gerencia (admin_id)"
    usuarios ||--o{ matriculas : "possui (aluno_id)"
    escolas ||--o{ matriculas : "contem (escola_id)"
    usuarios ||--o{ sessoes_simulado : "inicia (aluno_id)"
    sessoes_simulado ||--o{ respostas : "pertence (sessao_id)"
    questoes ||--o{ respostas : "responde (questao_id)"

    usuarios {
        uuid id PK
        varchar nome_completo
        varchar papel
        uuid auth_id
    }
    escolas {
        uuid id PK
        varchar nome
        varchar cnpj UK
        uuid admin_id FK
    }
    matriculas {
        uuid id PK
        uuid aluno_id FK
        uuid escola_id FK
    }
    questoes {
        uuid id PK
        jsonb conteudo
        timestamp criado_em
    }
    sessoes_simulado {
        uuid id PK
        uuid aluno_id FK
        timestamp data_inicio
        timestamp data_fim
        varchar estado
        int total_questoes
        int total_acertos
    }
    respostas {
        uuid id PK
        uuid sessao_id FK
        uuid questao_id FK
        int alternativa_escolhida
        boolean acertou
        timestamp data_registro
    }