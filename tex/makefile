.SUFFIXES:	.tex .dvi .ps .pdf .aux .log .toc .lof .lot .bbl .bib .blg

### �v���O���� ###
TEX=		platex
BIBTEX=		jbibtex -min-crossrefs=0 
DVIOUT=		/usr/share/dviout/dviout.exe
DVIPS=		dvipsk
RM=			rm -f

### �f�[�^ ###
SOURCEDIR=	.
NAME=		index

### �^�[�Q�b�g ###
all:		$(NAME).dvi
dvi:		$(NAME).dvi
bbl:		$(NAME).bbl
ps:			$(NAME).ps
pdf:		$(NAME).pdf
view:		$(NAME).dvi
			$(DVIOUT) $< &

### �ˑ��֌W ###
$(NAME).dvi:	$(NAME).tex outjis.txt
$(NAME).ps:		$(NAME).dvi 
$(NAME).pdf:	$(NAME).ps
$(NAME).aux:	$(NAME).log
outjis.txt:		out.txt
			nkf -W8 -s out.txt > outjis.txt

### �T�t�B�N�X�E���[�� ###
.tex.dvi:
			$(TEX) $<
			(while egrep '^No file $*.lo' $*.log; \
				do	$(TEX) $<; \
				done)
			(while egrep 'Warning: There were undefined citations.' $*.log; \
				do	$(BIBTEX) $*; \
					$(TEX) $<; \
				done)
			(while egrep 'Citation\(s\) may have changed' $*.log; \
				do	$(TEX) $<; \
				done)
			(while egrep '^LaTeX Warning: Label\(s\) may have changed.' $*.log; \
				do	$(TEX) $<; \
				done)
			(if egrep '^LaTeX Warning: There were undefined references.' $*.log; \
				then	$(TEX) $<; \
				fi)
			(if egrep '^LaTeX Warning: There were undefined references.' $*.log; \
				then	cat $(NAME).log | grep "undefined on"; \
				fi)
.tex.aux:
			$(TEX) $<
.bib.bbl:
			$(BIBTEX) $*
.dvi.ps:
			$(DVIPS) -D1200 -t a4 -Ppdf -G0 -f -z $^ | bkmk2uni > $@
.ps.pdf:
			start $^
do:
			nkf -W8 -s out.txt > outjis.txt
			$(TEX) $(NAME).tex
clean:
			$(RM) *~
			$(RM) $(NAME).{aux,log,nav,out,dvi,pdf,ps,snm,tag,toc}