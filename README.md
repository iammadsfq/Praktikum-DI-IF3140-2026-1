# Praktikum 5 — Data Integration (ELT) | IF3140

Repositori starter untuk **Praktikum 5: Data Integration (ELT)** mata kuliah **IF3140 Sistem Basis Data**, Program Studi Teknik Informatika, STEI ITB.

## Quick Start

Pastikan **Docker Desktop** (Windows/macOS) atau **Docker Engine** (Linux) aktif, lalu jalankan:

```bash
docker compose up -d --build
docker compose exec -it elt-runner bash
```

Ikuti instruksi pengerjaan lengkap pada **Dokumen Teknis** dan **Worksheet Praktikum 5** yang dibagikan.

## Struktur Repositori

```text
.
├── docker-compose.yml          # Container postgres-oltp & elt-runner
├── docker/Dockerfile.elt       # Image elt-runner (Sling CLI, DuckDB CLI, psql)
├── source/                     # Skrip SQL untuk database sumber (PostgreSQL OLTP)
├── el/                         # File konfigurasi Sling CLI [TODO]
├── transform/                  # Skrip SQL transformasi di DuckDB [TODO]
├── scripts/                    # Skrip helper (dijalankan di dalam container elt-runner)
└── data/                       # (Otomatis) Lokasi file DuckDB `basdat_dwh.duckdb`
```

## Referensi Resmi
- Sling CLI: https://docs.slingdata.io/
- DuckDB: https://duckdb.org/docs/
- PostgreSQL: https://www.postgresql.org/docs/
