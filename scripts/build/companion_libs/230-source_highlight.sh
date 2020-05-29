# Build script for Source-highlight

do_source_highlight_get() { :; }
do_source_highlight_extract() { :; }
do_source_highlight_for_build() { :; }
do_source_highlight_for_host() { :; }
do_source_highlight_for_target() { :; }

if [ "${CT_SOURCE_HIGHLIGHT}" = "y" ]; then

do_source_highlight_get() {
    CT_Fetch SOURCE_HIGHLIGHT
}

do_source_highlight_extract() {
    CT_ExtractPatch SOURCE_HIGHLIGHT
}

# Build source-highlight for running on build
do_source_highlight_for_build() {
    local -a source_highlight_opts

    case "${CT_TOOLCHAIN_TYPE}" in
        native|cross)   return 0;;
    esac

    CT_DoStep INFO "Installing source-highlight for build"
    CT_mkdir_pushd "${CT_BUILD_DIR}/build-source-highlight-build-${CT_BUILD}"

    source_highlight_opts+=( "host=${CT_BUILD}" )
    source_highlight_opts+=( "prefix=${CT_BUILDTOOLS_PREFIX_DIR}" )
    source_highlight_opts+=( "cflags=${CT_CFLAGS_FOR_BUILD}" )
    source_highlight_opts+=( "ldflags=${CT_LDFLAGS_FOR_BUILD}" )
    do_source_highlight_backend "${source_highlight_opts[@]}"

    CT_Popd

    if [ -n "${CT_CLEAN_AFTER_BUILD_STEP}" ]; then
        CT_DoLog EXTRA "Cleaning build-source-highlight-build-${CT_BUILD} directory"
        CT_DoForceRmdir "${CT_BUILD_DIR}/build-source-highlight-build-${CT_BUILD}"
    fi

    CT_EndStep
}

# Build source-highlight for running on host
do_source_highlight_for_host() {
    local -a source_highlight_opts

    CT_DoStep INFO "Installing source-highlight for host"
    CT_mkdir_pushd "${CT_BUILD_DIR}/build-source-highlight-host-${CT_HOST}"

    source_highlight_opts+=( "host=${CT_HOST}" )
    source_highlight_opts+=( "prefix=${CT_HOST_COMPLIBS_DIR}" )
    source_highlight_opts+=( "cflags=${CT_CFLAGS_FOR_HOST}" )
    source_highlight_opts+=( "ldflags=${CT_LDFLAGS_FOR_HOST}" )
    do_source_highlight_backend "${source_highlight_opts[@]}"

    CT_Popd

    if [ -n "${CT_CLEAN_AFTER_BUILD_STEP}" ]; then
        CT_DoLog EXTRA "Cleaning build-source-highlight-host-${CT_HOST} directory"
        CT_DoForceRmdir "${CT_BUILD_DIR}/build-source-highlight-host-${CT_HOST}"
    fi

    CT_EndStep
}

# Build source-highlight
#     Parameter     : description               : type      : default
#     host          : machine to run on         : tuple     : (none)
#     prefix        : prefix to install into    : dir       : (none)
#     shared        : build shared lib          : bool      : no
#     cflags        : host cflags to use        : string    : (empty)
#     ldflags       : host ldflags to use       : string    : (empty)
do_source_highlight_backend() {
    local host
    local prefix
    local shared
    local cflags
    local ldflags
    local arg
    local -a extra_config

    for arg in "$@"; do
        eval "${arg// /\\ }"
    done

    if [ "${shared}" != "y" ]; then
        extra_config+=("--disable-shared")
    fi

    case "${CT_BUILD}" in
        *darwin*)
            # Mixing static and dynamic libraries with clang in this case is
            # easier said than done. Fall back to dynamic linking the boost
            # library on macOS/clang for now.
            ;;
        *)
            extra_config+=("--with-boost-regex=:libboost_regex.a")
            ;;
    esac

    CT_DoLog EXTRA "Configuring source-highlight"

    # Regenerate the build system to skip the broken documentation build.
    #
    # Note that the documentation build process relies on the compiled host
    # executable and does not work when cross-compiling.
    CT_Pushd ${CT_SRC_DIR}/source-highlight
    CT_DoExecLog CFG autoreconf -if
    CT_Popd

    CT_DoExecLog CFG                                          \
    CFLAGS="${cflags}"                                        \
    LDFLAGS="${ldflags}"                                      \
    ${CONFIG_SHELL}                                           \
    "${CT_SRC_DIR}/source-highlight/configure"                \
        --build=${CT_BUILD}                                   \
        --host="${host}"                                      \
        --prefix="${prefix}"                                  \
        --enable-static                                       \
        "${extra_config[@]}"                                  \

    CT_DoLog EXTRA "Building source-highlight"
    CT_DoExecLog ALL make CC="${host}-gcc ${cflags}" ${CT_JOBSFLAGS}

    CT_DoLog EXTRA "Installing source-highlight"
    CT_DoExecLog ALL make install CC="${host}-gcc ${cflags}"
}

fi
