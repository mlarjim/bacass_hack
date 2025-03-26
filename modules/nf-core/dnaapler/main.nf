process DNAAPLER {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/dnaapler:1.2.0--pyhdfd78af_0' :
        'biocontainers/dnaapler:1.2.0--pyhdfd78af_0' }"

    input:
    tuple val(meta) , path(assembly)

    output:
    tuple val(meta), path("${prefix}.fasta")                   , emit: reoriented
    tuple val(meta), path("${prefix}.tsv")                     , emit: tsv
    path "versions.yml"                                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args      = task.ext.args   ?: ''
    prefix        = task.ext.prefix ?: "${meta.id}"
    """
    dnaapler all \\
        --input $assembly \\
        --output $prefix \\
        --database dnaa \\
        --threads $task.cpus \\
        --force 

    ln -s ${prefix}/dnaapler_all_reorientation_summary.tsv ${prefix}.tsv
    ln -s ${prefix}/dnaapler_reoriented.fasta ${prefix}.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dnaapler: \$(dnaapler --version 2>&1 | sed 's/^.*dnaapler, version //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def args      = task.ext.args   ?: ''
    prefix        = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p $prefix
    touch $prefix/dnaapler_all_reorientation_summary.tsv
    touch $prefix/dnaapler_reoriented.fasta

    ln -s ${prefix}/dnaapler_all_reorientation_summary.tsv ${prefix}.tsv
    ln -s ${prefix}/dnaapler_reoriented.fasta ${prefix}.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dnaapler: \$(dnaapler --version 2>&1 | sed 's/^.*dnaapler, version //; s/ .*\$//')
    END_VERSIONS
    """
}
