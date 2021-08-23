nextflow.enable.dsl = 2

include { TBBWA } from '../../modules/mtbseq/tbbwa/tbbwa.nf' addParams (params.TBBWA)
include { TBREFINE } from '../../modules/mtbseq/tbrefine/tbrefine.nf' addParams (params.TBREFINE)
include { TBPILE } from '../../modules/mtbseq/tbpile/tbpile.nf' addParams (params.TBPILE)
include { TBLIST } from '../../modules/mtbseq/tblist/tblist.nf' addParams (params.TBLIST)
include { TBVARIANTS } from '../../modules/mtbseq/tbvariants/tbvariants.nf' addParams (params.TBVARIANTS)
include { TBSTATS } from '../../modules/mtbseq/tbstats/tbstats.nf' addParams (params.TBSTATS)
include { TBSTRAINS } from '../../modules/mtbseq/tbstrains/tbstrains.nf' addParams (params.TBSTRAINS)
include { TBJOIN } from '../../modules/mtbseq/tbjoin/tbjoin.nf' addParams (params.TBJOIN)
include { TBAMEND } from '../../modules/mtbseq/tbamend/tbamend.nf' addParams (params.TBAMEND)
include { TBGROUPS } from '../../modules/mtbseq/tbgroups/tbgroups.nf' addParams (params.TBGROUPS)

workflow COHORT_ANALYSIS {
    take:
        genome_names
        position_variants
        position_tables

    main:
        samples_tsv_file = genomes_names
                .collect()
                .flatten().map { n -> "$n" + "\t" + "${params.library_name}" + "\n" }
                .collectFile(name: params.samplesheet_name, newLine: false, storeDir: "${params.outdir}")

        TBJOIN(position_variants.collect(),
               position_tables.collect(),
               samples_tsv_file,
               params.gatk38_jar,
               params.user)

        TBAMEND(TBJOIN.out.joint_samples,
                samples_tsv_file,
                params.gatk38_jar,
                params.user)

        TBGROUPS(TBAMEND.out.samples_amended,
                 samples_tsv_file,
                 params.gatk38_jar,
                 params.user)

}
