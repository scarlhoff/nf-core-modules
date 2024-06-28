process VCF2GENOME {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vcf2genome:0.91--hdfd78af_2':
        'biocontainers/vcf2genome:0.91--hdfd78af_2' }"

    input:
    tuple val(meta), path(vcf)
    file(fasta)

    output:
    tuple val(meta), path("*.fasta.gz"), emit: fasta
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args ?: ''
    def args3 = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def vcf_input = vcf.extension == "gz" ? "gzip $args -cdn $vcf > ${prefix}.vcf" : ""
    """
    $vcf_input

    vcf2genome \\
        $args2 \\
        -in ${prefix}.vcf \\
        -ref $fasta \\
        -draft ${prefix}.fasta

    gzip $args3 -cn ${prefix}.fasta > ${prefix}.fasta.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vcf2genome: \$(vcf2genome |& awk 'NR==1{print $3}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "" | gzip -c > ${prefix}.fasta.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vcf2genome: \$(vcf2genome |& awk 'NR==1{print $3}')
    END_VERSIONS
    """
}
