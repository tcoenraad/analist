CREATE TABLE users (
    id integer NOT NULL,
    email character varying,
    username character varying,
    password_digest character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    first_name character varying NOT NULL,
    last_name_prefix character varying,
    last_name character varying NOT NULL,
    birthday date
);
