-module(test).

-export([run_query/1,start_driver/0,benchmark/1]).

% -record(myrec, {field1, field2}).

start_driver() -> 
	application:start(asn1),
	application:start(crypto),
	application:start(public_key),
	application:start(ssl),
	application:start(pooler),
	application:start(re2), 
	application:start(semver),
	application:start(snappy),
	application:start(lz4),
	application:start(quickrand),
	application:start(uuid),   
	application:start(cqerl),
	{ok, Cli} = cqerl:get_client("127.0.0.1:9042", [{keyspace, cycling}]),
	Cli.

benchmark(Cli) ->
	{MS, S, US} = os:timestamp(),
    erlang:apply(run_query,[Cli]),
    {MS2, S2, US2} = os:timestamp(),
    {MS2-MS,S2-S,US2-US}.

run_query(Cli) -> 
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(1, 'tsesar', 'trp12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(2, 'tsesar2', 'rtp12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(3, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(4, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(5, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(6, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(7, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(8, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(9, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(10, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(11, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(12, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(13, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(14, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(15, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(16, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(17, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(18, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(19, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(20, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(21, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(22, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(23, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(24, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(25, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(26, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(27, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(28, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(29, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(30, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(31, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(32, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(33, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(34, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(35, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(36, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(37, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(38, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(39, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(40, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(41, 'tsesar3', 'trp12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(42, 'tsesar2', 'rtp12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(43, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(44, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(45, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(46, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(47, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(48, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(49, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(50, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(51, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(52, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(53, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(54, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(55, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(56, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(57, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(58, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(59, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(60, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(61, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(62, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(63, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(64, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(65, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(66, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(67, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(68, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(69, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(70, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(71, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(72, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(73, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(74, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(75, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(76, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(77, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(78, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(79, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(80, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(81, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(82, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(83, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(84, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(85, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(86, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(87, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(88, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(89, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(90, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(91, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(92, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(93, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(94, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(95, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(96, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(97, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(98, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(99, 'tsesar3', 'ptr12345', 1);"),
	cqerl:run_query(Cli, "INSERT INTO users(id, name, password, count) VALUES(100, 'tsesar3', 'ptr12345', 1);").