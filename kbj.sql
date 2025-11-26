/*
 Navicat Premium Data Transfer

 Source Server         : tes_lokal
 Source Server Type    : PostgreSQL
 Source Server Version : 130022 (130022)
 Source Host           : 127.0.0.1:8888
 Source Catalog        : kbj_db
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 130022 (130022)
 File Encoding         : 65001

 Date: 26/11/2025 13:29:24
*/


-- ----------------------------
-- Sequence structure for kunjungan_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."kunjungan_id_seq";
CREATE SEQUENCE "public"."kunjungan_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for list_user_id_user_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."list_user_id_user_seq";
CREATE SEQUENCE "public"."list_user_id_user_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for pasien_no_rm_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."pasien_no_rm_seq";
CREATE SEQUENCE "public"."pasien_no_rm_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for soapi_id_soapi_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."soapi_id_soapi_seq";
CREATE SEQUENCE "public"."soapi_id_soapi_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for unit_id_unit_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."unit_id_unit_seq";
CREATE SEQUENCE "public"."unit_id_unit_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Table structure for kunjungan
-- ----------------------------
DROP TABLE IF EXISTS "public"."kunjungan";
CREATE TABLE "public"."kunjungan" (
  "id" int8 NOT NULL DEFAULT nextval('kunjungan_id_seq'::regclass),
  "id_unit" int4 NOT NULL,
  "no_rm" int8 NOT NULL,
  "waktu_masuk" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "waktu_keluar" timestamp(6)
)
;

-- ----------------------------
-- Records of kunjungan
-- ----------------------------
INSERT INTO "public"."kunjungan" VALUES (1, 1, 1, '2025-11-12 13:17:56', NULL);
INSERT INTO "public"."kunjungan" VALUES (2, 1, 3, '2025-11-12 13:18:08', NULL);
INSERT INTO "public"."kunjungan" VALUES (3, 1, 1, '2025-11-19 08:45:14', NULL);
INSERT INTO "public"."kunjungan" VALUES (4, 1, 2, '2025-11-19 18:17:39', NULL);

-- ----------------------------
-- Table structure for list_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."list_user";
CREATE TABLE "public"."list_user" (
  "id_user" int4 NOT NULL DEFAULT nextval('list_user_id_user_seq'::regclass),
  "nama" varchar(255) COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::character varying
)
;

-- ----------------------------
-- Records of list_user
-- ----------------------------
INSERT INTO "public"."list_user" VALUES (1, 'Tes User');

-- ----------------------------
-- Table structure for pasien
-- ----------------------------
DROP TABLE IF EXISTS "public"."pasien";
CREATE TABLE "public"."pasien" (
  "no_rm" int8 NOT NULL DEFAULT nextval('pasien_no_rm_seq'::regclass),
  "nama" varchar(255) COLLATE "pg_catalog"."default",
  "alamat" varchar(255) COLLATE "pg_catalog"."default",
  "tgl_lahir" varchar(255) COLLATE "pg_catalog"."default",
  "jns_kelamin" int2 NOT NULL DEFAULT 2
)
;
COMMENT ON COLUMN "public"."pasien"."jns_kelamin" IS '0: female, 1: male, 2: other';

-- ----------------------------
-- Records of pasien
-- ----------------------------
INSERT INTO "public"."pasien" VALUES (1, 'Andi Pratama', 'Jl. Merdeka No. 10, Jakarta', '1990-03-12', 1);
INSERT INTO "public"."pasien" VALUES (2, 'Siti Aisyah', 'Jl. Anggrek No. 5, Bandung', '1992-07-25', 0);
INSERT INTO "public"."pasien" VALUES (3, 'Budi Santoso', 'Jl. Diponegoro No. 8, Surabaya', '1985-11-02', 1);
INSERT INTO "public"."pasien" VALUES (4, 'Rina Kurniawati', 'Jl. Malioboro No. 3, Yogyakarta', '1994-01-18', 0);
INSERT INTO "public"."pasien" VALUES (5, 'Agus Saputra', 'Jl. Gatot Subroto No. 21, Medan', '1988-09-07', 1);
INSERT INTO "public"."pasien" VALUES (6, 'Dewi Lestari', 'Jl. Pettarani No. 15, Makassar', '1996-05-30', 0);
INSERT INTO "public"."pasien" VALUES (7, 'Fajar Hidayat', 'Jl. Pandanaran No. 12, Semarang', '1991-12-14', 1);
INSERT INTO "public"."pasien" VALUES (8, 'Nadia Putri', 'Jl. Margonda No. 88, Depok', '1993-04-09', 0);
INSERT INTO "public"."pasien" VALUES (9, 'Rizky Ramadhan', 'Jl. Pajajaran No. 7, Bogor', '1997-06-22', 1);
INSERT INTO "public"."pasien" VALUES (10, 'Intan Maharani', 'Jl. Ijen No. 19, Malang', '1989-10-05', 0);

-- ----------------------------
-- Table structure for soapi
-- ----------------------------
DROP TABLE IF EXISTS "public"."soapi";
CREATE TABLE "public"."soapi" (
  "id_soapi" int8 NOT NULL DEFAULT nextval('soapi_id_soapi_seq'::regclass),
  "id_user" int4 NOT NULL,
  "id_kunjungan" int8 NOT NULL,
  "waktu_dibuat" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "waktu_dokumen" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  "s" text COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::text,
  "o" text COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::text,
  "a" text COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::text,
  "p" text COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::text,
  "i" text COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::text,
  "aktif" bool NOT NULL DEFAULT false
)
;

-- ----------------------------
-- Records of soapi
-- ----------------------------
INSERT INTO "public"."soapi" VALUES (1, 1, 1, '2025-11-12 07:04:03.133625', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, Dukungan pengungkapan perasaan, Edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (5, 1, 1, '2025-11-12 11:41:55.558962', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (56, 1, 1, '2025-11-19 19:35:41.39549', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg.', 'Pasien tampak kurang tenang.', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 't');
INSERT INTO "public"."soapi" VALUES (40, 1, 1, '2025-11-19 14:55:27.357868', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (49, 1, 1, '2025-11-19 17:30:29.856033', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 'f');
INSERT INTO "public"."soapi" VALUES (51, 1, 1, '2025-11-19 17:51:44.928216', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (53, 1, 1, '2025-11-19 18:00:36.129852', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 'f');
INSERT INTO "public"."soapi" VALUES (41, 1, 1, '2025-11-19 17:12:07.253826', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (54, 1, 1, '2025-11-19 18:09:06.065004', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg.', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 'f');
INSERT INTO "public"."soapi" VALUES (47, 1, 1, '2025-11-19 17:29:28.007654', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 'f');
INSERT INTO "public"."soapi" VALUES (48, 1, 1, '2025-11-19 17:29:28.230315', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (50, 1, 1, '2025-11-19 17:50:29.816078', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg.', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 'f');
INSERT INTO "public"."soapi" VALUES (52, 1, 1, '2025-11-19 17:58:46.264039', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (42, 1, 1, '2025-11-19 17:13:27.059418', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (55, 1, 1, '2025-11-19 18:16:29.794036', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg.', 'Pasien tampak kurang tenang dan kemrungsung.', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 'f');
INSERT INTO "public"."soapi" VALUES (43, 1, 1, '2025-11-19 17:18:43.897325', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (44, 1, 1, '2025-11-19 17:23:39.546975', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (45, 1, 1, '2025-11-19 17:24:45.48689', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (46, 1, 1, '2025-11-19 17:26:38.598782', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang dan kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan.', 'f');
INSERT INTO "public"."soapi" VALUES (3, 1, 1, '2025-11-12 10:14:04.092529', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, Dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');
INSERT INTO "public"."soapi" VALUES (4, 1, 1, '2025-11-12 10:14:12.130678', '2025-11-12 07:04:03', 'Pasien mengeluh sulit tidur, sering dredeg', 'Pasien tampak kurang tenang, kemrungsung', '40|ANSIETAS', 'Kolaborasi medis, Dukungan pengungkapan perasaan, edukasi kepatuhan minum obat dan kontrol', 'Implementasikan tindakan keperawatan sesuai perencanaan', 'f');

-- ----------------------------
-- Table structure for unit
-- ----------------------------
DROP TABLE IF EXISTS "public"."unit";
CREATE TABLE "public"."unit" (
  "id_unit" int4 NOT NULL DEFAULT nextval('unit_id_unit_seq'::regclass),
  "nama" varchar(255) COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::character varying
)
;

-- ----------------------------
-- Records of unit
-- ----------------------------
INSERT INTO "public"."unit" VALUES (1, 'Poli Jantung');
INSERT INTO "public"."unit" VALUES (2, 'Poli Orthopedi');

-- ----------------------------
-- Table structure for unit_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."unit_user";
CREATE TABLE "public"."unit_user" (
  "id_user" int4 NOT NULL,
  "id_unit" int4 NOT NULL
)
;

-- ----------------------------
-- Records of unit_user
-- ----------------------------
INSERT INTO "public"."unit_user" VALUES (1, 1);

-- ----------------------------
-- Function structure for update_last_soapi
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."update_last_soapi"();
CREATE OR REPLACE FUNCTION "public"."update_last_soapi"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
	DECLARE
		last_revisi TIMESTAMP;
	BEGIN
		UPDATE soapi
		SET aktif = 'f'
		WHERE waktu_dokumen = NEW.waktu_dokumen
		AND id_kunjungan = NEW.id_kunjungan
		AND waktu_dibuat <= NEW.waktu_dibuat;
		
		SELECT waktu_dibuat INTO last_revisi
		FROM soapi
		WHERE waktu_dokumen = NEW.waktu_dokumen
		AND id_kunjungan = NEW.id_kunjungan
		ORDER BY waktu_dibuat DESC;
		
		IF last_revisi > NEW.waktu_dibuat THEN
			NEW.aktif := 'f';
		ELSE
			NEW.aktif := 't';
		END IF;
	RETURN NEW;
END$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."kunjungan_id_seq"
OWNED BY "public"."kunjungan"."id";
SELECT setval('"public"."kunjungan_id_seq"', 4, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."list_user_id_user_seq"
OWNED BY "public"."list_user"."id_user";
SELECT setval('"public"."list_user_id_user_seq"', 1, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."pasien_no_rm_seq"
OWNED BY "public"."pasien"."no_rm";
SELECT setval('"public"."pasien_no_rm_seq"', 10, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."soapi_id_soapi_seq"
OWNED BY "public"."soapi"."id_soapi";
SELECT setval('"public"."soapi_id_soapi_seq"', 56, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."unit_id_unit_seq"
OWNED BY "public"."unit"."id_unit";
SELECT setval('"public"."unit_id_unit_seq"', 2, true);

-- ----------------------------
-- Primary Key structure for table kunjungan
-- ----------------------------
ALTER TABLE "public"."kunjungan" ADD CONSTRAINT "kunjungan_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table list_user
-- ----------------------------
ALTER TABLE "public"."list_user" ADD CONSTRAINT "list_user_pkey" PRIMARY KEY ("id_user");

-- ----------------------------
-- Primary Key structure for table pasien
-- ----------------------------
ALTER TABLE "public"."pasien" ADD CONSTRAINT "pasien_pkey" PRIMARY KEY ("no_rm");

-- ----------------------------
-- Triggers structure for table soapi
-- ----------------------------
CREATE TRIGGER "update_last_soapi" BEFORE INSERT ON "public"."soapi"
FOR EACH ROW
EXECUTE PROCEDURE "public"."update_last_soapi"();

-- ----------------------------
-- Primary Key structure for table soapi
-- ----------------------------
ALTER TABLE "public"."soapi" ADD CONSTRAINT "soapi_pkey" PRIMARY KEY ("id_soapi");

-- ----------------------------
-- Primary Key structure for table unit
-- ----------------------------
ALTER TABLE "public"."unit" ADD CONSTRAINT "unit_pkey" PRIMARY KEY ("id_unit");

-- ----------------------------
-- Primary Key structure for table unit_user
-- ----------------------------
ALTER TABLE "public"."unit_user" ADD CONSTRAINT "unit_user_pkey" PRIMARY KEY ("id_user", "id_unit");

-- ----------------------------
-- Foreign Keys structure for table kunjungan
-- ----------------------------
ALTER TABLE "public"."kunjungan" ADD CONSTRAINT "kunjungan_pasien" FOREIGN KEY ("no_rm") REFERENCES "public"."pasien" ("no_rm") ON DELETE SET NULL ON UPDATE SET NULL;
ALTER TABLE "public"."kunjungan" ADD CONSTRAINT "kunjungan_unit" FOREIGN KEY ("id_unit") REFERENCES "public"."unit" ("id_unit") ON DELETE SET NULL ON UPDATE SET NULL;

-- ----------------------------
-- Foreign Keys structure for table soapi
-- ----------------------------
ALTER TABLE "public"."soapi" ADD CONSTRAINT "soapi_list_user" FOREIGN KEY ("id_user") REFERENCES "public"."list_user" ("id_user") ON DELETE SET NULL ON UPDATE SET NULL;

-- ----------------------------
-- Foreign Keys structure for table unit_user
-- ----------------------------
ALTER TABLE "public"."unit_user" ADD CONSTRAINT "unit_user_list_user" FOREIGN KEY ("id_user") REFERENCES "public"."list_user" ("id_user") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."unit_user" ADD CONSTRAINT "unit_user_unit" FOREIGN KEY ("id_unit") REFERENCES "public"."unit" ("id_unit") ON DELETE CASCADE ON UPDATE CASCADE;
