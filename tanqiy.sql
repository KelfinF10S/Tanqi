-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 02 Jun 2026 pada 09.12
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tanqiy`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `bab`
--

CREATE TABLE `bab` (
  `id` int(10) NOT NULL,
  `judul` varchar(255) NOT NULL,
  `locked` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `bab`
--

INSERT INTO `bab` (`id`, `judul`, `locked`) VALUES
(1, ' أنواع الكلمة', 1),
(2, 'المعرب والمبني', 1),
(3, 'انواع الجمل', 1),
(4, 'انواع التراكيب والأساليب', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `soal`
--

CREATE TABLE `soal` (
  `id` int(10) NOT NULL,
  `pertanyaan` varchar(255) NOT NULL,
  `opsi_a` varchar(255) NOT NULL,
  `opsi_b` varchar(255) NOT NULL,
  `opsi_c` varchar(255) NOT NULL,
  `opsi_d` varchar(255) NOT NULL,
  `jawaban_benar` varchar(1) NOT NULL,
  `xp_reward` int(10) NOT NULL DEFAULT 0,
  `babid` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `user`
--

CREATE TABLE `user` (
  `id` int(10) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(1000) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `xp` int(10) NOT NULL DEFAULT 0,
  `level` int(2) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user`
--

INSERT INTO `user` (`id`, `username`, `password`, `created_at`, `xp`, `level`) VALUES
(1, 'kelfin', 'scrypt:32768:8:1$GKXsGvhTgmOQlxun$1c6ab6a4d087fa6d7dc3ed4d6f01ca51501ceb6cbfe7ddba6a8ba8cd355b47517a6d3b9638d3588827f834de71dafd37b892e485edb72f6cd71c3dac17e3fa6f', '2026-05-31 23:28:34', 0, 1),
(2, 'wahyu', 'scrypt:32768:8:1$SlIUPppH4zPzjtOu$1e8f0a23443b35f158d7fd3c8c1da0340712cf9a22b1c53b326ee747b2296b1d21872efb7851324bda30ed674b3abe5088078acb20990c97f334eed4b1bbc318', '2026-05-31 23:45:28', 0, 1),
(3, 'taylor', 'scrypt:32768:8:1$ZL6yLYapEKmvHMxS$cb91585d6187989f708f6400f358d193c09762f34f4ce6321e4a2b5cc967cdecfe2a002df9eeccaa492b1629cc24a21f6ea30ed26537b5f16a8b9102c660cc65', '2026-06-01 22:38:49', 0, 1),
(4, 'admin', 'scrypt:32768:8:1$NoyhQmFu0bv0Hoaf$2ea6b337cbe03e0205e4c2cc5f483677ae4ab2682693482c7fd833e133cd675b4d610d7ade91d8cf95270732f802d167051ba1a0d1c20fde2f50cea0a6dc9402', '2026-06-01 22:40:27', 0, 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_jawaban`
--

CREATE TABLE `user_jawaban` (
  `id` int(10) NOT NULL,
  `jawaban_user` varchar(1) NOT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT 0,
  `xp_didapat` int(10) NOT NULL DEFAULT 0,
  `anwsered_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `userid` int(10) NOT NULL,
  `soalid` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `bab`
--
ALTER TABLE `bab`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `soal`
--
ALTER TABLE `soal`
  ADD PRIMARY KEY (`id`),
  ADD KEY `babid` (`babid`);

--
-- Indeks untuk tabel `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `password` (`password`) USING HASH;

--
-- Indeks untuk tabel `user_jawaban`
--
ALTER TABLE `user_jawaban`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userid` (`userid`),
  ADD KEY `soalid` (`soalid`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `bab`
--
ALTER TABLE `bab`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `soal`
--
ALTER TABLE `soal`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `user`
--
ALTER TABLE `user`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `user_jawaban`
--
ALTER TABLE `user_jawaban`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `soal`
--
ALTER TABLE `soal`
  ADD CONSTRAINT `soal_ibfk_1` FOREIGN KEY (`babid`) REFERENCES `bab` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `user_jawaban`
--
ALTER TABLE `user_jawaban`
  ADD CONSTRAINT `user_jawaban_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_jawaban_ibfk_2` FOREIGN KEY (`soalid`) REFERENCES `soal` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
