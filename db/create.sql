-- Original publishers of stories - Digg, Slashdot, etc.
create table publishers (
    id                  int             not null unique auto_increment,

    -- e.g. 'Digg'
    name                char(20)        not null unique,
	-- URL-safe equivalent of the name above
	safe_name			char(20)		not null unique,

    -- e.g. 'http://digg.com'
    url                 varchar(255)    not null unique,
    -- when created in our DB
    created_at          timestamp       not null,
    -- when last updated in our DB (useful for updater polling)
    updated_at          timestamp       not null,

    primary key(id),

    index (id),
    index (url),
	index (safe_name)
);

-- Hierarchical news topics on a per publisher basis
create table publisher_topics (
    id                  int             not null unique auto_increment,
    publisher_id        int             not null,
    -- if this topic is a subtopic of another topic, parent_id is not null
    parent_id           int             null,

    -- name of the topic (e.g., "Tech News")
    name                varchar(255)    not null,
    -- URL-safe name of the topic (e.g., "tech-news")
    safe_name           char(50),
    -- is this just a topic folder? (topic folders only have subtopics, there are no stories published directly under such topics)
    folder              int(1)          not null,

    -- when created in our database
    created_at          timestamp       not null,
    -- when last updated in our database
    updated_at          timestamp       not null,

    primary key(id),

    foreign key (publisher_id) references publishers (id),
    foreign key (parent_id) references publisher_topics (id),

    index (id),
    index (publisher_id),
    index (parent_id),
    index (name),
    index (safe_name)
) character set utf8;

-- users who publish stories at the publisher site, on a per-publisher basis
create table publisher_users (
    id                  int             not null unique auto_increment,
    publisher_id        int             not null,

    -- user name with the publisher (e.g., 'karlack')
    -- we assume that a link to user profile path at the publisher site can be recovered with this data
    name                varchar(255)    not null,

    primary key (id),

    foreign key (publisher_id) references publishers (id),

    index (id),
    index (publisher_id)
);

create table stories (
    id                  int             not null unique auto_increment,
    publisher_id        int             not null,
    publisher_user_id   int             not null,

    -- when this entry was created in our database
    created_at          timestamp       not null,
    -- when this entry was last updated in our database
    updated_at          timestamp       not null,

    -- when the story was originally submitted to the publisher (by its author/user)
    submitted_at        timestamp       not null,
    -- when the story was promoted by the publisher (e.g., Digg front page)
    promoted_at         timestamp       not null,

    title               varchar(255)    not null,
    description         text            not null,

    -- home link of the story
    source_url          varchar(255)    not null,
    -- story page with the publisher (e.g., story discussion page on Digg)
    publisher_url       varchar(255)    not null,

    -- story ID with the publisher (e.g., Digg internal story ID)
    publisher_story_id  int             not null,
    -- number of comments for the story at the publisher
    publisher_comments  int             not null,
    -- number of votes for the story at the publisher (if available)
    publisher_votes     int,

    primary key (id),

    foreign key (publisher_id) references publishers (id),
    foreign key (publisher_user_id) references publisher_users (id),

    index (id),
    index (publisher_id),
    index (publisher_user_id)
) character set utf8;

-- many-to-many relationship between topics and stories
create table publisher_topics_stories (
    publisher_topic_id  int             not null,
    story_id            int             not null,

    primary key (publisher_topic_id, story_id),

    index (publisher_topic_id, story_id)
);

-- our own users
create table users (
    id                  int             not null unique auto_increment,

    login               varchar(100)    not null unique,
    password            char(40)        not null,
    email               varchar(255)    null,
    active              int (1)         not null,

    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    top_story_id        int             null,
    bottom_story_id     int             null,


    primary key (id),

    foreign key (bottom_story_id) references stories (id),

    index (id),
    index (active)
);

-- user preferences w.r.t. publisher topics - which categories the user monitors
create table user_topics (
    id                  int             not null unique auto_increment,

    publisher_topic_id  int             not null,
    user_id             int             not null,
    bottom_story_id     int             null,

    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    primary key (id),

    foreign key (publisher_topic_id) references publisher_topics (id),
    foreign key (user_id) references users (id),
    foreign key (bottom_story_id) references stories (id),

    index (id),
    index (publisher_topic_id),
    index (user_id)
);

create table story_statuses (
    id                  int             not null unique auto_increment,

    name                char (20)       not null unique,

    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    primary key (id)
);

-- story statuses for users
create table stories_story_statuses_users (
    story_id            int             not null,
    story_status_id     int             not null,
    user_id             int             not null,

    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    primary key (story_id, story_status_id, user_id),

    foreign key (story_id) references stories (id),
    foreign key (story_status_id) references story_statuses (id),
    foreign key (user_id) references users (id),

    index (story_id, story_status_id, user_id)
);

-- journals

create table journals (
    id                  int             not null unique auto_increment,
    user_id             int             not null,

    name                varchar(255)    not null,
    safe_name           char(50)        not null,

    direction           int             not null,
    page                int             not null,
    active              int(1)          not null,
	stories_per_page	int				not null,

    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    primary key (id),
    foreign key (user_id) references users (id),

    index (id),
    index (user_id),
	index (safe_name)
);

-- journal topics (many-to-many)

create table journals_publisher_topics (
    journal_id          int             not null,
    publisher_topic_id  int             not null,

    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    primary key (journal_id, publisher_topic_id),

    foreign key (journal_id) references journals (id),
    foreign key (publisher_topic_id) references publisher_topics (id),

    index (journal_id, publisher_topic_id)
);

-- journal bookmarks

create table journal_bookmarks (
    id                  int             not null unique auto_increment,
    journal_id          int             not null,
    user_id             int             not null,

    page                int             not null,
    
    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    description         varchar(255)    null,

    primary key (id),

    foreign key (journal_id) references journals (id),
    foreign key (user_id) references users (id),

    index (id),
    index (journal_id),
    index (user_id)
);

-- story pins
create table story_pins (
    id                  int             not null unique auto_increment,
    user_id             int             not null,
    journal_id          int             not null,
    story_id            int             not null,

    created_at          timestamp       not null,
    updated_at          timestamp       not null,

    primary key (id),

    foreign key (user_id) references users (id),
    foreign key (journal_id) references journals (id),
    foreign key (story_id) references stories (id),

    index (id),
    index (user_id),
    index (journal_id),
    index (story_id)
);

-- bookmarks
create table bookmarks (
    id                  int             not null unique auto_increment,
	
);
