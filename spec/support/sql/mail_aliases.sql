CREATE TABLE mail_aliases (
    id bigint NOT NULL,
    email character varying,
    moderation_type character varying,
    description character varying,
    group_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);
