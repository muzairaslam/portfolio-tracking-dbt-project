{{ config(materialized="ephemeral") }}
with

    src_data as (
        select
            account_id as account_code,  -- TEXT
            symbol as security_code,  -- TEXT
            description as security_name,  -- TEXT
            exchange as exchange_code,  -- TEXT
            report_date as report_date,  -- DATE
            quantity as quantity,  -- NUMBER
            cost_base as cost_base,  -- NUMBER
            position_value as position_value,  -- NUMBER
            currency as currency_code,  -- TEXT
            'SOURCE_DATA.ABC_BANK_POSITION' as record_source

        from {{ source("abc_bank", "ABC_BANK_POSITION") }}

    ),

    hashed as (
        select
            concat_ws('|', account_code, security_code) as position_hkey,
            concat_ws(
                '|',
                account_code,
                security_code,
                security_name,
                exchange_code,
                report_date,
                quantity,
                cost_base,
                position_value,
                currency_code
            ) as position_hdiff,
            *,
            '{{ run_started_at }}'::timestamp as load_ts_utc
        from src_data
    )

select *
from hashed
