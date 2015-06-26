ifndef __SDSCDEVEL_COMMONROLLS_MK
__SDSCDEVEL_COMMONROLLS_MK = yes

# Makes ROLLDEF calls (see RollStack.mk) for all SDSC rolls that aren't
# specific to a particular cluster.  include this file after including
# RollStack.mk and after defining these make vars:
#
# * MULTI_COMPILER - list of compiler modules to be loaded by rolls that can be
#     built and rolled with more than one compiler
# * MULTI_MPI - list of mpi modules to be loaded by rolls that can be built and
#     rolled with more than one mpi flavor
# * %-ROLLOPTS - optional package-specific ROLLOPTS values

# Implicit roll prereqs, not derived from ROLL{COMPILER,MPI,PY}
abyss_PREREQS = boost
beast_PREREQS = beagle
biotools_PREREQS = boost cmake fftw gnucompiler hdf math
chemistry_PREREQS = cmake fftw
cilk_PREREQS = gnucompiler
cpmd_PREREQS = fftw
gaussian_PREREQS = pgi
geo_PREREQS = R
grace_PREREQS = fftw netcdf
gnutools_PREREQS = gnucompiler
guile_PREREQS = gnucompiler gnutools
jags_PREREQS = math R
math_PREREQS = cmake fftw gnucompiler hdf
mpi_PREREQS = gnutools
ncl_PREREQS = hdf netcdf
netcdf_PREREQS = hdf
octave_PREREQS = fftw hdf
polymake_PREREQS = boost gnucompiler
r-modules_PREREQS = netcdf R
siesta_PREREQS = hdf netcdf
trilinos_PREREQS = cmake
vasp_PREREQS = fftw
vtk_PREREQS = cmake

# Complete roll set categorized by ROLLCOMPILER value...
DEFAULT_COMPILER_ROLLS = \
  abyss amber beagle beast biotools chemistry cpmd gamess geo grace jags \
  mpi4py nwchem octave performance polymake python R scipy siesta upc vasp vtk
MULTI_COMPILER_ROLLS = \
  atlas boost fftw fpmpi hdf math mpi netcdf trilinos
NO_COMPILER_ROLLS = \
  beast2 blcr cilk cmake data-transfer ddt fsa gaussian gnucompiler gnutools \
  guile hadoop idl intel mono nagios pgi r-modules rapidminer stata weka

# ... and again by ROLLMPI value.
DEFAULT_MPI_ROLLS = \
  abyss amber chemistry cpmd gamess grace mpi4py nwchem performance r-modules \
  siesta upc vasp vtk
MULTI_MPI_ROLLS = \
  fftw hdf math fpmpi netcdf trilinos
NO_MPI_ROLLS = \
  atlas beagle beast beast2 biotools blcr boost cilk cmake data-transfer ddt \
  fsa gaussian geo gnucompiler gnutools guile hadoop idl intel jags mono mpi \
  nagios octave polymake pgi python R rapidminer scipy stata weka

# Rolls that support ROLLPY make var
PYTHON_ROLLS = hdf math mpi4py scipy trilinos

ALL_ROLLS = $(sort $(DEFAULT_COMPILER_ROLLS) $(MULTI_COMPILER_ROLLS) $(NO_COMPILER_ROLLS))

# A couple of rolls that are known to have build failures w/the pgi compilers
NO_PGI_ROLLS = boost trilinos

# Rolls not available from github, generally because of a paid license
RESTRICTED_ROLLS = amber ddt gaussian idl intel pgi stata vasp

# gmake's handling of line continuations makes it difficult to format call
# invocations readably.  Placing the call into a variable to be passed to eval
# is at least better than squishing everything onto a single line.
DEFINE_ALL_ROLLS = \
$$(foreach roll,$$(ALL_ROLLS), \
  $$(call ROLLDEF, \
          $$(roll), \
          $$(if $$(filter $$(roll),$$(MULTI_COMPILER_ROLLS)),ROLLCOMPILER=$$(MULTI_COMPILER)), \
          $$(if $$(filter $$(roll),$$(NO_PGI_ROLLS)),ROLLCOMPILER=$$(MULTI_COMPILER:pgi=)), \
          $$(if $$(filter $$(roll),$$(NO_COMPILER_ROLLS)),ROLLCOMPILER=), \
          $$(if $$(filter $$(roll),$$(MULTI_MPI_ROLLS)),ROLLMPI=$$(MULTI_MPI)), \
          $$(if $$(filter $$(roll),$$(NO_MPI_ROLLS)),ROLLMPI=), \
          $$(if $$(filter $$(roll),$$(PYTHON_ROLLS)),ROLLPY=python), \
          PREREQS=$$($$(roll)_PREREQS), \
          $$(if $$($$(roll)_ROLLOPTS),ROLLOPTS=$$($$(roll)_ROLLOPTS)), \
  ) \
)
comma := ,
empty :=
space := $(empty) $(empty)
$(eval $(subst $(comma)$(space),$(comma),$(DEFINE_ALL_ROLLS)))

# TODO: incorporate these rolls into above lists
#cern-roll
#cgns-roll
#cipres-roll
#dppdiv-roll
#fsl-roll
#knime-roll
#julia-roll
#matlab-roll
#migrate-roll
#molden-roll
#mpiblast-roll
#mrbayes-roll
#neuron-roll
#p3dfft-roll
#paraview-roll
#phylobayes-roll
#qchem-roll
#qe-roll
#rabbitmq-roll
#raxml-roll
#seedme-roll
#visit-roll
#vmd-roll

endif # __SDSCDEVEL_COMMONROLLS_MK
