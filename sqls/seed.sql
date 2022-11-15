CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

DROP TABLE IF EXISTS
    public.users,
    public.issues,
    public.issue_links,
    public.labels,
    public.label_links
    CASCADE;

DROP TYPE IF EXISTS public.issue_link_type_enum;

CREATE TABLE public.users (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    username         VARCHAR(200),
    firstname        VARCHAR(200),
    lastname         VARCHAR(200),

    created_at       TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at       TIMESTAMP WITHOUT TIME ZONE,

    CONSTRAINT       valid_username UNIQUE (username)
);
CREATE INDEX public_users_username_index   ON public.users (username);
CREATE INDEX public_users_firstname_index  ON public.users (firstname);
CREATE INDEX public_users_lastname_index   ON public.users (lastname);
CREATE INDEX public_users_created_at_index ON public.users (created_at);
CREATE INDEX public_users_updated_at_index ON public.users (updated_at);

CREATE TABLE public.issues (
    id                             UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    title                          VARCHAR(200) NOT NULL,
    markdown_description           TEXT DEFAULT NULL,

    created_by                     UUID DEFAULT NULL,
    last_updated_by                UUID DEFAULT NULL,

    created_at                     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at                     TIMESTAMP WITHOUT TIME ZONE,

    CONSTRAINT fk_created_by       FOREIGN KEY (created_by) REFERENCES public.users (id) ON DELETE SET NULL,
    CONSTRAINT fk_last_updated_by  FOREIGN KEY (last_updated_by) REFERENCES public.users (id) ON DELETE SET NULL
);
CREATE INDEX public_issues_title_index              ON public.issues (title);
CREATE INDEX public_issues_created_by_index         ON public.issues (created_by);
CREATE INDEX public_issues_last_updated_by_at_index ON public.issues (last_updated_by);
CREATE INDEX public_issues_created_at_index         ON public.issues (created_at);
CREATE INDEX public_issues_updated_at_index         ON public.issues (updated_at);

CREATE TYPE public.issue_link_type_enum AS ENUM (
    'BLOCKS',
    'IS_BLOCKED_BY'
);

CREATE TABLE public.issue_links (
    id                            UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    source_issue_id               UUID NOT NULL,
    target_issue_id               UUID NOT NULL,
    link_type                     issue_link_type_enum DEFAULT NULL,

    created_by                    UUID DEFAULT NULL,
    created_at                    TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),

    CONSTRAINT fk_source_issue_id FOREIGN KEY (source_issue_id) REFERENCES public.issues (id) ON DELETE CASCADE,
    CONSTRAINT fk_target_issue_id FOREIGN KEY (target_issue_id) REFERENCES public.issues (id) ON DELETE CASCADE,
    CONSTRAINT fk_created_by      FOREIGN KEY (created_by)      REFERENCES public.users  (id) ON DELETE SET NULL
);
CREATE INDEX public_issue_links_source_issue_id_index ON public.issue_links (source_issue_id);
CREATE INDEX public_issue_links_target_issue_id_index ON public.issue_links (target_issue_id);
CREATE INDEX public_issue_links_created_by_index      ON public.issue_links (created_by);
CREATE INDEX public_issue_links_created_at_index      ON public.issue_links (created_at);

CREATE TABLE public.labels (
    id                             UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    name                           VARCHAR(40) NOT NULL,
    description                    VARCHAR(200) DEFAULT NULL,

    created_by                     UUID DEFAULT NULL,
    last_updated_by                UUID DEFAULT NULL,
    closed_by                      UUID DEFAULT NULL,

    created_at                     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at                     TIMESTAMP WITHOUT TIME ZONE,
    closed_at                      TIMESTAMP WITHOUT TIME ZONE,

    CONSTRAINT fk_created_by       FOREIGN KEY (created_by)      REFERENCES public.users (id) ON DELETE SET NULL,
    CONSTRAINT fk_last_updated_by  FOREIGN KEY (last_updated_by) REFERENCES public.users (id) ON DELETE SET NULL,
    CONSTRAINT fk_closed_by        FOREIGN KEY (closed_by)       REFERENCES public.users (id) ON DELETE SET NULL
);
CREATE INDEX public_labels_name_index               ON public.labels (name);
CREATE INDEX public_labels_created_by_index         ON public.labels (created_by);
CREATE INDEX public_labels_last_updated_by_at_index ON public.labels (last_updated_by);
CREATE INDEX public_labels_closed_by_at_index       ON public.labels (closed_by);
CREATE INDEX public_labels_created_at_index         ON public.labels (created_at);
CREATE INDEX public_labels_updated_at_index         ON public.labels (updated_at);
CREATE INDEX public_labels_closed_at_index          ON public.labels (closed_at);

CREATE TABLE public.label_links (
    id                       UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    label_id                 UUID NOT NULL,
    issue_id                 UUID NOT NULL,
    created_by               UUID DEFAULT NULL,
    created_at               TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),

    CONSTRAINT fk_label_id   FOREIGN KEY (label_id)   REFERENCES public.labels (id) ON DELETE CASCADE,
    CONSTRAINT fk_issue_id   FOREIGN KEY (issue_id)   REFERENCES public.issues (id) ON DELETE CASCADE,
    CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES public.users  (id) ON DELETE SET NULL
);
CREATE INDEX public_label_links_label_id_index   ON public.label_links (label_id);
CREATE INDEX public_label_links_issue_id_index   ON public.label_links (issue_id);
CREATE INDEX public_label_links_created_by_index ON public.label_links (created_by);
CREATE INDEX public_label_links_created_at_index ON public.label_links (created_at);
