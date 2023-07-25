PY_IMAGE_SET=$(shell ls genI*py | sed 's/genI/.i/; s/\.py/.dat/')
PROC_IMAGE_SET=$(shell ls genProcI*.sh | sed 's/genProcI/.i/; s/\.sh/.dat/')

all: ${PY_IMAGE_SET} ${PROC_IMAGE_SET} 
	( say done 2&> /dev/null ) || ( echo done | espeak  )

$(PY_IMAGE_SET): .image_%.dat: genImage_%.py
	./$< 
	touch $@

$(PROC_IMAGE_SET): .image_%.dat: genProcImage_%.sh ExpressionGen/Example_%.pde
	sh ./$< 
	touch $@

clean:
	rm -f *.png *.gif .*.dat
	rm -rf __pycache__ 

