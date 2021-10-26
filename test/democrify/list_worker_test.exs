defmodule Democrify.SessionWorkerTest do
  use ExUnit.Case

  alias Democrify.Session.Song
  alias Democrify.Session.Worker, as: Worker

  setup do
    session_id = 12

    Democrify.Session.Registry.delete(session_id)

    worker_pid = Democrify.Session.Registry.create(session_id)

    %{session_id: session_id, worker_pid: worker_pid}
  end

  test "Start Worker and Add Songs", %{worker_pid: worker_pid} do
    assert [] == Worker.fetch_all(worker_pid)

    song1 = %Song{id: 1, votes: 0}

    assert [song1] == Worker.add(worker_pid, %Song{})
    assert [song1] == Worker.fetch_all(worker_pid)

    song2 = %Song{id: 2, votes: 0}

    assert [song1, song2] == Worker.add(worker_pid, %Song{})
    assert [song1, song2] == Worker.fetch_all(worker_pid)

    song3 = %Song{id: 3, votes: 0}

    assert [song1, song2, song3] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3] == Worker.fetch_all(worker_pid)

    song4 = %Song{id: 4, votes: 0}

    assert [song1, song2, song3, song4] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3, song4] == Worker.fetch_all(worker_pid)
  end

  test "Ordering of Songs", %{worker_pid: worker_pid} do
    song1 = %Song{id: 1, votes: 0}
    song2 = %Song{id: 2, votes: 0}
    song3 = %Song{id: 3, votes: 0}
    song4 = %Song{id: 4, votes: 0}

    assert [song1] == Worker.add(worker_pid, %Song{})
    assert [song1, song2] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3, song4] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3, song4] == Worker.fetch_all(worker_pid)

    # Bump song 2

    song2 = %{song2 | votes: 1}

    assert [song2, song1, song3, song4] == Worker.increment(worker_pid, song2)
    assert [song2, song1, song3, song4] == Worker.fetch_all(worker_pid)

    # Bump song 4

    song4 = %{song4 | votes: 1}

    assert [song2, song4, song1, song3] == Worker.increment(worker_pid, song4)
    assert [song2, song4, song1, song3] == Worker.fetch_all(worker_pid)

    # Bump song 4

    song4 = %{song4 | votes: 2}

    assert [song4, song2, song1, song3] == Worker.increment(worker_pid, song4)
    assert [song4, song2, song1, song3] == Worker.fetch_all(worker_pid)

    # Bump song 3

    song3 = %{song3 | votes: 1}

    assert [song4, song2, song3, song1] == Worker.increment(worker_pid, song3)
    assert [song4, song2, song3, song1] == Worker.fetch_all(worker_pid)

    # Bump song 2

    song2 = %{song2 | votes: 2}

    assert [song4, song2, song3, song1] == Worker.increment(worker_pid, song2)
    assert [song4, song2, song3, song1] == Worker.fetch_all(worker_pid)
  end

  test "Bumping Unknown Song", %{worker_pid: worker_pid} do
    song1 = %Song{id: 1, votes: 0}
    song2 = %Song{id: 2, votes: 0}
    song3 = %Song{id: 3, votes: 0}
    song4 = %Song{id: 4, votes: 0}

    assert [song1] == Worker.add(worker_pid, %Song{})
    assert [song1, song2] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3, song4] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3, song4] == Worker.fetch_all(worker_pid)

    assert [song1, song2, song3, song4] == Worker.increment(worker_pid, %Song{id: 6})
    assert [song1, song2, song3, song4] == Worker.fetch_all(worker_pid)
  end

  test "fetch Individual Song", %{worker_pid: worker_pid} do
    song1 = %Song{id: 1, votes: 0}
    song2 = %Song{id: 2, votes: 0}
    song3 = %Song{id: 3, votes: 0}
    song4 = %Song{id: 4, votes: 0}

    assert [song1] == Worker.add(worker_pid, %Song{})
    assert [song1, song2] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3, song4] == Worker.add(worker_pid, %Song{})
    assert [song1, song2, song3, song4] == Worker.fetch_all(worker_pid)

    assert song1 == Worker.fetch(worker_pid, 1)
    assert song2 == Worker.fetch(worker_pid, 2)
    assert song3 == Worker.fetch(worker_pid, 3)
    assert song4 == Worker.fetch(worker_pid, 4)
  end
end
