-- Extensão para geração de UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Gestão de Identidade
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_completo VARCHAR(255) NOT NULL,
    papel VARCHAR(50) DEFAULT 'aluno' CHECK (papel IN ('aluno', 'admin_escolar', 'admin_global')),
    auth_id UUID UNIQUE NOT NULL -- FK para sistema de autenticação externo
);

-- 2. Estrutura Escolar
CREATE TABLE escolas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    admin_id UUID REFERENCES usuarios(id) -- Administrador específico da escola
);

CREATE TABLE matriculas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    aluno_id UUID REFERENCES usuarios(id),
    escola_id UUID REFERENCES escolas(id),
    UNIQUE(aluno_id, escola_id) -- Impede matrícula duplicada na mesma escola
);

-- 3. Banco de Questões
CREATE TABLE questoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conteudo JSONB NOT NULL, -- Enunciado e alternativas
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Dinâmica de Simulados
CREATE TABLE sessoes_simulado (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    aluno_id UUID REFERENCES usuarios(id),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fim TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'em andamento' CHECK (estado IN ('em andamento', 'concluida')),
    total_questoes INTEGER DEFAULT 0,
    total_acertos INTEGER DEFAULT 0
);

CREATE TABLE respostas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sessao_id UUID REFERENCES sessoes_simulado(id) ON DELETE CASCADE,
    questao_id UUID REFERENCES questoes(id) ON DELETE CASCADE,
    alternativa_escolhida INTEGER NOT NULL,
    acertou BOOLEAN NOT NULL,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sessao_id, questao_id) -- Impede múltiplas respostas para mesma questão na sessão
);

CREATE OR REPLACE FUNCTION inicializar_perfil_usuario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO usuarios (auth_id, nome_completo, papel)
    VALUES (NEW.id, NEW.nome, 'aluno'); -- Exemplo assumindo trigger em tabela de auth externa
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE matriculas ENABLE ROW LEVEL SECURITY;

-- Exemplo de política para Alunos
CREATE POLICY aluno_acesso_proprio ON matriculas
    FOR SELECT TO authenticated_user
    USING (aluno_id = current_user_id());

-- Exemplo de política para Admin Escolar
CREATE POLICY admin_acesso_escola ON matriculas
    FOR SELECT TO admin_escolar
    USING (escola_id IN (SELECT id FROM escolas WHERE admin_id = current_user_id()));
    