<?php

namespace App\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;

class ToDoListForm extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('name', TextType::class)
            ->add('description', TextareaType::class)
            ->add('importance', ChoiceType::class, [
                'choices' => [
                    'Very important' => 'Very important',
                    'Important' => 'Important',
                    'Normal' => 'Normal',
                    'Not important' => 'Not important',
                ],
            ])
            ->add('save', SubmitType::class);
    }
}